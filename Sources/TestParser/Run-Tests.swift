import Foundation
@_exported import SwiftCommand

extension TestParser {
    @MainActor
    public func run(
        _ scope: TestRunnable,
        lineHandle: @escaping (String) -> Void
    ) async throws {
        let process = try await Command.findInPath(withName: "swift")!
            .setCWD(path)
            .addArgument("test")
            .addArgument("--test-product")
            .addArgument(scope.testProductName)
            .addArgument("--filter")
            .addArgument(scope.filter)
            .setStdout(.pipe)
            .spawn()
        
        for try await line in process.stdout.lines {
            lineHandle(line)
        }
    }
}
