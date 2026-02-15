import Foundation
import SystemPackage
@_exported import SwiftCommand

extension TestParser {
    @MainActor
    public func run(
        _ scope: TestRunnable,
        lineHandle: @escaping (String) throws -> Void
    ) async throws {
        let process = try await Command.findInPath(withName: "swift")!
            .setCWD(FilePath(pathString))
            .addArgument("test")
            .addArgument("--test-product")
            .addArgument(scope.testProductName)
            .addArgument("--filter")
            .addArgument(scope.filter)
            .setStdout(.pipe)
            .spawn()
        
        for try await line in process.stdout.lines {
            try lineHandle(line)
        }
    }
}
