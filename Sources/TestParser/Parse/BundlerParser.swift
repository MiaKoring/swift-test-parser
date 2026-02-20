import TOMLKit
import SwiftCommand
import SystemPackage

public struct BundlerParser {
    let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func parse() throws -> [String] {
        guard
            let tomlString = try? String(
                contentsOfFile: "\(path)/Bundler.toml",
                encoding: .utf8
            )
        else { return [] }
        
        let toml = try TOMLTable(string: tomlString)
        
        let result = toml["apps"]
        
        return result?.table?.keys ?? []
    }
    
    public func simulators() async throws -> [String: String] {
        let process = try await Command.findInPath(withName: "swift-bundler")!
            .addArgument("simulators")
            .addArgument("list")
            .setStdout(.pipe)
            .spawn()
        
        var simulators = [String: String]()
        
        for try await line in process.stdout.lines {
            guard
                line.hasPrefix("* "),
                let dividerIndex = line.firstIndex(of: ":")
            else { continue }
            let nameStart = line.index(dividerIndex, offsetBy: 2)
            
            let id = line.dropFirst(2).prefix(36)
            let name = String(line[nameStart...])
            
            simulators[name] = String(id)
        }
        
        return simulators
    }
    
    public func runAppCommand(
        named name: String,
        environment: [String: String],
        arguments: [String]
    ) async throws -> Command<UnspecifiedInputSource, PipeOutputDestination, UnspecifiedOutputDestination> {
        var process = try await Command.findInPath(withName: "swift-bundler")!
            .setCWD(FilePath(path))
            .setEnvVariables(environment)
            .addArgument("run")
            .addArgument(name)
            .addArguments(arguments)
            .setStdout(.pipe)
        
        return process
    }
}
