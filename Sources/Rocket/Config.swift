import Foundation
import PathKit
import TOMLKit

struct Config {
    let templatesPath: Path
    let outputPath: Path
    let assetsPaths: [Path]
    let ignoredPaths: [Path]
    
    init(
        templatesPath: Path = defaultTemplatesPath,
        outputPath: Path = defaultOutputPath,
        assetsPaths: [Path] = [defaultAssetsPath],
        ignoredPaths: [Path] = []
    ) {
        self.templatesPath = templatesPath
        self.outputPath = outputPath
        self.assetsPaths = assetsPaths
        self.ignoredPaths = ignoredPaths
    }
}


extension Config {
    static func loadDefault() throws -> Config {
        guard let path = try Path.current.children().first(where: { $0.url.lastPathComponent.hasPrefix(configFileName) }) else {
            return Config()
        }
        
        switch path.url.pathExtension {
        case "toml":
            let decoder = TOMLDecoder()
            return try decoder.decode(Config.self, from: path.read())
            
        case "json":
            let decoder = JSONDecoder()
            return try decoder.decode(Config.self, from: Data(contentsOf: path.url))
            
        default:
            throw UnsupportedConfigurationFileFormat(format: path.url.pathExtension)
        }
    }
}


// MARK: Decoding

extension Config: Decodable {
    enum CodingKeys: String, CodingKey {
        case templatesPath
        case outputPath
        case assetsPaths
        case ignoredPaths
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let templateRelativePath = try container.decodeIfPresent(String.self, forKey: .templatesPath) ?? Self.defaultTemplatesDirectoryName
        self.templatesPath = .current + Path(templateRelativePath)
        
        let outputRelativePath = try container.decodeIfPresent(String.self, forKey: .outputPath) ?? Self.defaultOutputDirectoryName
        self.outputPath = .current + Path(outputRelativePath)
        
        let assetsRelativePaths = try container.decodeIfPresent([String].self, forKey: .assetsPaths) ?? [Self.defaultOutputDirectoryName]
        self.assetsPaths = assetsRelativePaths.map { .current + Path($0) }
        
        let ignoredRelativePaths = try container.decodeIfPresent([String].self, forKey: .ignoredPaths) ?? []
        self.ignoredPaths = ignoredRelativePaths.map { .current + Path($0) }
    }
}


// MARK: Defaults

extension Config {
    static let configFileName = "rocket"
    
    static let defaultTemplatesDirectoryName = "templates"
    static var defaultTemplatesPath: Path { .current + Path(defaultTemplatesDirectoryName) }
    
    static let defaultOutputDirectoryName = "dist"
    static var defaultOutputPath: Path { .current + Path(defaultOutputDirectoryName) }
    
    static let defaultAssetsDirectoryName = "assets"
    static var defaultAssetsPath: Path { .current + Path(defaultAssetsDirectoryName) }
}
