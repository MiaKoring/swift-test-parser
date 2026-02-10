public final class TargetTests: @unchecked Sendable {
    public let targetName: String
    public var freestanding = Set<Test>()
    public var suites = [TestSuite]()
    public let testProductName: String
    
    init(targetName: String, testProductName: String) {
        self.targetName = targetName
        self.testProductName = testProductName
    }
}

extension TargetTests: TestRunnable {
    public var filter: String {
        "\(targetName)"
    }
}
