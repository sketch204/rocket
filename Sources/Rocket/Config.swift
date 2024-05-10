import Foundation
import PathKit
import TOMLKit

struct Config {
    let postsPath: Path
    
    let templatesPath: Path
    let includesPath: Path
    let outputPath: Path
    let assetsPaths: [Path]
    let ignoredPaths: [Path]
    
    let baseURL: String
    
    let userProperties: [String: Any]
    
    init(
        postsPath: Path = defaultPostsPath,
        templatesPath: Path = defaultTemplatesPath,
        includesPath: Path = defaultIncludesPath,
        outputPath: Path = defaultOutputPath,
        assetsPaths: [Path] = [defaultAssetsPath],
        ignoredPaths: [Path] = [],
        baseURL: String = "",
        userProperties: [String: Any] = [:]
    ) {
        self.postsPath = postsPath
        
        self.templatesPath = templatesPath
        self.includesPath = includesPath
        self.outputPath = outputPath
        self.assetsPaths = assetsPaths
        self.ignoredPaths = ignoredPaths
        self.baseURL = baseURL
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
    static let postsPath = Self(stringValue: "postsPath")
    static let templatesPath = Self(stringValue: "templatesPath")
    static let includesPath = Self(stringValue: "includesPath")
    static let outputPath = Self(stringValue: "outputPath")
    static let assetsPaths = Self(stringValue: "assetsPaths")
    static let ignoredPaths = Self(stringValue: "ignoredPaths")
    static let baseURL = Self(stringValue: "baseURL")
}

extension Config: Decodable {
    init(from decoder: any Decoder) throws {
        var userProperties = try Dictionary(from: decoder)
        
        let postsRelativePath = userProperties.removeValue(forKey: StringCodingKey.postsPath.stringValue) as? String ?? Self.defaultPostsDirectoryName
        postsPath = .current + Path(postsRelativePath)
        
        let templateRelativePath = userProperties.removeValue(forKey: StringCodingKey.templatesPath.stringValue) as? String ?? Self.defaultTemplatesDirectoryName
        templatesPath = .current + Path(templateRelativePath)
        
        let includesRelativePath = userProperties.removeValue(forKey: StringCodingKey.includesPath.stringValue) as? String ?? Self.defaultIncludesDirectoryName
        includesPath = .current + Path(includesRelativePath)
        
        let outputRelativePath = userProperties.removeValue(forKey: StringCodingKey.outputPath.stringValue) as? String ?? Self.defaultOutputDirectoryName
        outputPath = .current + Path(outputRelativePath)
        
        let assetsRelativePaths = userProperties.removeValue(forKey: StringCodingKey.assetsPaths.stringValue) as? [String] ?? [Self.defaultAssetsDirectoryName]
        assetsPaths = assetsRelativePaths.map { .current + Path($0) }
        
        let ignoredRelativePaths = userProperties.removeValue(forKey: StringCodingKey.ignoredPaths.stringValue) as? [String] ?? []
        ignoredPaths = ignoredRelativePaths.map { .current + Path($0) }
        
        var baseURL = userProperties.removeValue(forKey: StringCodingKey.baseURL.stringValue) as? String ?? ""
        if baseURL.hasSuffix("/") {
            baseURL.removeLast()
        }
        self.baseURL = baseURL
        
        self.userProperties = userProperties
    }
}


// MARK: Defaults

extension Config {
    static let configFileName = "rocket"
    
    static let defaultPostsDirectoryName = "posts"
    static var defaultPostsPath: Path { .current + Path(defaultPostsDirectoryName) }
    
    static let defaultTemplatesDirectoryName = "templates"
    static var defaultTemplatesPath: Path { .current + Path(defaultTemplatesDirectoryName) }
    
    static let defaultIncludesDirectoryName = "includes"
    static var defaultIncludesPath: Path { .current + Path(defaultIncludesDirectoryName) }
    
    static let defaultOutputDirectoryName = "dist"
    static var defaultOutputPath: Path { .current + Path(defaultOutputDirectoryName) }
    
    static let defaultAssetsDirectoryName = "assets"
    static var defaultAssetsPath: Path { .current + Path(defaultAssetsDirectoryName) }
}
