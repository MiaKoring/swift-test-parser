import Foundation
import SystemPackage
@_exported import SwiftCommand

@MainActor
public struct TestRunner {
    let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func run(
        _ scope: TestRunnable,
        outputPath: String,
        lineHandle: @escaping (String) throws -> Void
    ) async throws {
        let process = try await Command.findInPath(withName: "swift")!
            .setCWD(FilePath(path))
            .addArgument("test")
            .addArgument("--test-product")
            .addArgument(scope.testProductName)
            .addArgument("--filter")
            .addArgument(scope.filter)
            .addArgument("--skip-build")
            .addArgument("--xunit-output")
            .addArgument(outputPath)
            .addArgument("--parallel")
            .setStdout(.pipe)
            .spawn()
        
        for try await line in process.stdout.lines {
            try lineHandle(line)
        }
    }
    
    public func build(
        _ product: String,
        lineHandle: @escaping (String) throws -> Void
    ) async throws {
        let process = try await Command.findInPath(withName: "swift")!
            .setCWD(FilePath(path))
            .addArgument("build")
            .addArgument("--product")
            .addArgument(product)
            .setStdout(.pipe)
            .spawn()
        
        for try await line in process.stdout.lines {
            try lineHandle(line)
        }
    }
}
