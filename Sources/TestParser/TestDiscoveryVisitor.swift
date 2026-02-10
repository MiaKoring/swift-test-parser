import Foundation
import MacroToolkit
import SwiftParser
import SwiftSyntax

class TestFinder: SyntaxVisitor {
    var discoveredSuites = [String: TestSuite]()
    var typeContextStack = [String]()
    
    let targetTests: TargetTests
    
    init(targetTests: TargetTests) {
        self.targetTests = targetTests
        
        super.init(viewMode: .fixedUp)
    }
    
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
                let suite = TestSuite(name: suiteName, structName: structName, target: targetTests)
                discoveredSuites[structName] = suite
                targetTests.suites.append(suite)
            } else {
                let suite = TestSuite(name: nil, structName: structName, target: targetTests)
                discoveredSuites[structName] = suite
                targetTests.suites.append(suite)
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
                addTestToCurrentScope(
                    name: testName,
                    functionName: functionName
                )
            } else {
                addTestToCurrentScope(
                    name: nil,
                    functionName: functionName
                )
            }
        }
        
        return .skipChildren
    }
    
    private func addTestToCurrentScope(name: String?, functionName: String) {
        var test = Test(name: name, functionName: functionName, target: targetTests)
        
        guard let suiteName = typeContextStack.last else {
            targetTests.freestanding.insert(test)
            return
        }
        
        let suite = discoveredSuites[suiteName] ?? TestSuite(name: nil, structName: suiteName, target: targetTests)
        
        test.suite = suite
        suite.tests.append(test)
        
        discoveredSuites[suiteName] = suite
    }
}
