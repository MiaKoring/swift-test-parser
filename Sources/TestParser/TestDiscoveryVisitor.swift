import Foundation
import MacroToolkit
import SwiftParser
import SwiftSyntax

class TestFinder: SyntaxVisitor {
    var discoveredSuites = [String: TestSuite]()
    var freestandingTests = Set<Test>()
    var typeContextStack = [String]()
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let structure = Struct(node)
        var testMacroDetected = false
        
        let structName = structure.identifier
        
        defer {
            typeContextStack.append(structName)
        }
        
        for attribute in node.attributes {
            // A struct is a Suite if it has @Suite attached to it
            // or it contains @Test functions
            guard
                let attr = attribute.as(AttributeSyntax.self),
                let macroAttr = Attribute(attr).asMacroAttribute,
                macroAttr.name.description == "Suite"
            else { continue }
            
            // Looking for a custom Suite name,
            // which can only be applied by @Suite
            if let suiteName = macroAttr.arguments.first?.expr.asStringLiteral?.value {
                discoveredSuites[structName] = TestSuite(name: suiteName, structName: structName)
            } else {
                discoveredSuites[structName] = TestSuite(name: nil, structName: structName)
            }
            
            // No need to check more attributes after @Suite was found
            return .visitChildren
        }
        
        return .visitChildren
    }
    
    override func visitPost(_ node: StructDeclSyntax) {
        _ = typeContextStack.removeLast()
    }
    
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = Extension(node).identifier
        typeContextStack.append(typeName)
        
        return .visitChildren
    }
    
    override func visitPost(_ node: ExtensionDeclSyntax) {
        _ = typeContextStack.removeLast()
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let function = Function(node)
        let functionName = function.identifier
        
        // static and class are unsupported
        // https://developer.apple.com/documentation/testing/organizingtests
        guard !node.modifiers.contains(where: { modifier in
            let kind = modifier.name.tokenKind
            
            return
            kind == .keyword(.static) || kind == .keyword(.class)
        }) else { return .skipChildren }
        
        for attribute in function.attributes {
            guard
                let macroAttr = attribute.attribute?.asMacroAttribute,
                macroAttr.name.description == "Test"
            else { continue }
            
            // Looking for a custom Test name,
            // which can only be applied by @Test
            if let testName = macroAttr.arguments.first?.expr.asStringLiteral?.value {
                addTestToCurrentScope(Test(name: testName, function: functionName))
            } else {
                addTestToCurrentScope(Test(name: nil, function: functionName))
            }
        }
        
        return .skipChildren
    }
    
    private func addTestToCurrentScope(_ test: Test) {
        guard let suiteName = typeContextStack.last else {
            freestandingTests.insert(test)
            return
        }
        
        if var suite = discoveredSuites[suiteName] {
            suite.tests.append(test)
            discoveredSuites[suiteName] = suite
            return
        }
        
        var suite = TestSuite(name: nil, structName: suiteName)
        suite.tests.append(test)
        
        discoveredSuites[suiteName] = suite
    }
}

public struct TestSuite: Hashable, Equatable {
    public let name: String?
    public let structName: String
    public var tests = [Test]()
    
    public static func == (lhs: TestSuite, rhs: TestSuite) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

public struct Test: Hashable, Equatable {
    public let name: String?
    public let function: String
    
    public static func == (lhs: Test, rhs: Test) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
