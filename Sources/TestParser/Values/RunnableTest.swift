public protocol TestRunnable: Sendable {
    var filter: String { get }
    var testProductName: String { get }
    var targetName: String { get }
    var uiFilter: String { get }
}
