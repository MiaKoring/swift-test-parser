import TOMLKit
import SwiftCommand
import SystemPackage

public struct BundlerParser {
    let path: String
    let sbunPath: String
    
    public init(path: String, sbunPath: String) {
        self.path = path
        self.sbunPath = sbunPath
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
        let process = try await Command(executablePath: FilePath(sbunPath))
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
    ) async throws -> Command<UnspecifiedInputSource, PipeOutputDestination, PipeOutputDestination> {
        let process = try await Command(executablePath: FilePath(sbunPath))
            .setEnvVariables(environment)
            .setCWD(FilePath(path))
            .addArgument("run")
            .addArgument(name)
            .addArguments(arguments)
            .setStdout(.pipe)
            .setStderr(.pipe)
        
        return process
    }
}
