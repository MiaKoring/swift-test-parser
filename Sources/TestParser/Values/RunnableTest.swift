public protocol TestRunnable: Sendable {
    var filter: String { get }
    var testProductName: String { get }
}
