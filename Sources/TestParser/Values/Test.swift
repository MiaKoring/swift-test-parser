public final class Test: Hashable, Equatable {
    public let name: String?
    public let functionName: String
    
    public let suite: TestSuite?
    public let target: TargetTests
    
    init(name: String?,
         functionName: String,
         suite: TestSuite? = nil,
         target: TargetTests
    ) {
        self.name = name
        self.functionName = functionName
        self.suite = suite
        self.target = target
    }
    
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
    public var targetName: String {
        target.targetName
    }
    
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
    
    public var uiFilter: String {
        let suiteSpecifier: String
        if let suite {
            if let name = suite.name {
                suiteSpecifier = ".\"\(name)\""
            } else {
                suiteSpecifier = ".\(suite.structName)"
            }
        } else {
            suiteSpecifier = ""
        }
        
        let nameSpecifier: String
        if let name = name {
            nameSpecifier = "\"\(name)\""
        } else {
            nameSpecifier = "\(functionName)"
        }
        return "\(target.targetName)\(suiteSpecifier)/\(nameSpecifier)"
    }
}
