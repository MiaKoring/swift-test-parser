import Foundation
import SystemPackage
import SwiftCommand

public struct TestParser: Sendable {
    let path: FilePath
    let pathString: String
    
    
    public init(path: String) {
        self.path = FilePath(path)
        self.pathString = path
    }
    
    /// Returns a list of identifiers of SPM `testTarget`s
    /// - Parameters:
    /// - at: The path of the directory containing Package.swift
    public func testTargets() async throws -> [Target] {
        let process = try await Command.findInPath(withName: "swift")!
            .setCWD(path)
            .addArgument("package")
            .addArgument("dump-package")
            .setStdout(.pipe)
            .spawn()
        
        var result = ""
        
        for try await line in process.stdout.lines {
            result.append("\n\(line)")
        }
        
        let parsed = try JSONDecoder()
            .decode(PackageDump.self, from: result.data(using: .utf8)!)
            .targets
            .compactMap {
                if $0.type == "test" {
                    return $0
                }
                return nil
            }
        
        return parsed
    }
}

struct PackageDump: Codable {
    let targets: [Target]
}

public struct Target: Codable, Hashable {
    public let name: String
    public let type: String
    public let path: String?
}
