public struct Test: Hashable, Equatable {
    public let name: String?
    public let functionName: String
    
    public internal(set) var suite: TestSuite?
    public let target: TargetTests
    
    public static func == (lhs: Test, rhs: Test) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension Test {
    public var untickedFunctionName: String {
        functionName.trimmingCharacters(in: ["`"])
    }
}

extension Test: TestRunnable {
    public var testProductName: String {
        target.testProductName
    }
    
    public var filter: String {
        let suiteSpecifier: String
        if let suite {
            suiteSpecifier = ".\(suite.structName)"
        } else {
            suiteSpecifier = ""
        }
        return "\(target.targetName)\(suiteSpecifier)/\(functionName)()"
    }
}
