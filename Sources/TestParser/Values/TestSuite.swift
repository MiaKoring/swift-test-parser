public final class TestSuite: Hashable, Equatable, @unchecked Sendable {
    public let name: String?
    public let structName: String
    public var tests = [Test]()
    
    public let target: TargetTests
    
    public init(
        name: String?,
        structName: String,
        tests: [Test] = [Test](),
        target: TargetTests
    ) {
        self.name = name
        self.structName = structName
        self.tests = tests
        self.target = target
    }
    
    public static func == (lhs: TestSuite, rhs: TestSuite) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension TestSuite {
    public var untickedStructName: String {
        structName.trimmingCharacters(in: ["`"])
    }
}

extension TestSuite: TestRunnable {
    public var testProductName: String {
        target.testProductName
    }
    
    public var filter: String {
        "\(target.targetName).\(structName)"
    }
}
