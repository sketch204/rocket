import Foundation
import PathKit
import TOMLKit

struct Config {
    let templatesPath: Path
    let outputPath: Path
    let assetsPaths: [Path]
    let ignoredPaths: [Path]
    
    let userProperties: [String: Any]
    
    init(
        templatesPath: Path = defaultTemplatesPath,
        outputPath: Path = defaultOutputPath,
        assetsPaths: [Path] = [defaultAssetsPath],
        ignoredPaths: [Path] = [],
        userProperties: [String: Any] = [:]
    ) {
        self.templatesPath = templatesPath
        self.outputPath = outputPath
        self.assetsPaths = assetsPaths
        self.ignoredPaths = ignoredPaths
        self.userProperties = userProperties
    }
}

extension Config {
    init(path: Path) throws {
        self = try path.decode(Self.self)
    }
    
    static func loadDefault() throws -> Config {
        guard let path = try Path.current.children().first(where: { $0.url.lastPathComponent.hasPrefix(configFileName) }) else {
            return Config()
        }
        
        return try Config(path: path)
    }
}


// MARK: Decoding

extension StringCodingKey {
    static var templatesPath: Self { Self(stringValue: "templatesPath") }
    static var outputPath: Self { Self(stringValue: "outputPath") }
    static var assetsPaths: Self { Self(stringValue: "assetsPaths") }
    static var ignoredPaths: Self { Self(stringValue: "ignoredPaths") }
}

extension Config: Decodable {
    init(from decoder: any Decoder) throws {
        var userProperties = try Dictionary(from: decoder)
        
        let templateRelativePath = userProperties.removeValue(forKey: StringCodingKey.templatesPath.stringValue) as? String ?? Self.defaultTemplatesDirectoryName
        templatesPath = .current + Path(templateRelativePath)
        
        let outputRelativePath = userProperties.removeValue(forKey: StringCodingKey.outputPath.stringValue) as? String ?? Self.defaultOutputDirectoryName
        outputPath = .current + Path(outputRelativePath)
        
        let assetsRelativePaths = userProperties.removeValue(forKey: StringCodingKey.assetsPaths.stringValue) as? [String] ?? [Self.defaultAssetsDirectoryName]
        assetsPaths = assetsRelativePaths.map { .current + Path($0) }
        
        let ignoredRelativePaths = userProperties.removeValue(forKey: StringCodingKey.ignoredPaths.stringValue) as? [String] ?? []
        ignoredPaths = ignoredRelativePaths.map { .current + Path($0) }
        
        self.userProperties = userProperties
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
