import Foundation
import SwiftParser
import SystemPackage


extension TestParser {
    public func tests(in target: Target) -> TargetTests {
        let targetPath = target.path ?? "\(pathString)/Tests/\(target.name)"
        let filePaths = getAllSwiftFilePaths(in: targetPath)
        
        let targetTests = TargetTests(targetName: target.name, testProductName: target.testProductName)
        
        let finder = TestFinder(targetTests: targetTests)
        
        for filePath in filePaths {
            guard
                let contents = FileManager.default.contents(atPath: filePath),
                let sourceString = String(data: contents, encoding: .utf8)
            else { continue }
            
            let sourceFile = Parser.parse(source: sourceString)
            
            finder.walk(sourceFile)
        }
        
        return targetTests
    }
    
    public func getAllSwiftFilePaths(in directoryPath: String) -> [String] {
        let url = URL(fileURLWithPath: directoryPath)
        let fileManager = FileManager.default
        var swiftFiles: [String] = []
        
        // Resource keys to pre-fetch for performance
        let keys: [URLResourceKey] = [.isRegularFileKey]
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants],
            errorHandler: { (url, error) -> Bool in
                // Return true to continue enumeration even if an error occurs
                return true
            }
        ) else {
            return []
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
                
                // Check if it's a file and has the .swift extension
                if resourceValues.isRegularFile == true && fileURL.pathExtension == "swift" {
                    swiftFiles.append(fileURL.path)
                }
            } catch {
                // Skip files where metadata cannot be read
                continue
            }
        }
        
        return swiftFiles
    }
}
