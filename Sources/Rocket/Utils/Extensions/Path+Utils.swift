import Foundation
import PathKit
import Stencil
import TOMLKit

// MARK: Standard Paths

extension Path {
    static func allSitePaths(config: Config) -> [Path] {
        Path.current.iterateChildren(options: [.skipsPackageDescendants, .skipsHiddenFiles])
            .filter { path in
                shouldSkip(path, config: config)
            }
    }
    
    static func allPostPaths(config: Config) -> [Path] {
        config.postsPath.iterateChildren(options: [.skipsPackageDescendants, .skipsHiddenFiles])
            .filter { path in
                !path.isDirectory
                && !path.isIgnored(config: config)
            }
    }
    
    static func allDataFilePaths(config: Config) -> [Path] {
        Path.current.iterateChildren(options: [.skipsPackageDescendants, .skipsHiddenFiles])
            .filter { path in
                !path.isIgnored(config: config)
                && !path.isInOutputPath(config: config)
                && !path.isInTemplatesPath(config: config)
                && !path.isInIncludesPath(config: config)
                && Set(arrayLiteral: "json", "toml", "yaml", "yml").contains(path.extension?.lowercased())
            }
    }
    
    static func allProcessableFilePaths(config: Config) -> [Path] {
        Path.current.iterateChildren(options: [.skipsPackageDescendants, .skipsHiddenFiles])
            .filter { path in
                !path.isIgnored(config: config)
                && !path.isInOutputPath(config: config)
                && !path.isInTemplatesPath(config: config)
                && !path.isInIncludesPath(config: config)
                && Set(arrayLiteral: "html", "md").contains(path.extension?.lowercased())
            }
    }
    
    private static func shouldSkip(_ path: Path, config: Config) -> Bool {
        return !path.isDirectory
        && !path.isConfigFile(config: config)
        && !path.isInOutputPath(config: config)
        && !path.isInTemplatesPath(config: config)
        && !path.isInIncludesPath(config: config)
        && !path.isInPostsPath(config: config)
        && !path.isIgnored(config: config)
    }
    
    func isConfigFile(config: Config) -> Bool {
        self.lastComponentWithoutExtension == Config.configFileName
    }
    
    func isInOutputPath(config: Config) -> Bool {
        matchesDirectory(config.outputPath)
    }
    
    func isInTemplatesPath(config: Config) -> Bool {
        matchesDirectory(config.templatesPath)
    }
    
    func isInIncludesPath(config: Config) -> Bool {
        matchesDirectory(config.includesPath)
    }
    
    func isInPostsPath(config: Config) -> Bool {
        matchesDirectory(config.postsPath)
    }
    
    func isIgnored(config: Config) -> Bool {
        config.ignoredPaths.contains { ignoredPath in
            if ignoredPath.isDirectory {
                matchesDirectory(ignoredPath)
            } else {
                ignoredPath ~= self
            }
        }
    }
    
    func matchesDirectory(_ path: Path) -> Bool {
        self.match("\(path.string)/*")
    }
}

extension Path {
    func relative(to parentPath: Path = .current, includeLeadingSlash: Bool = true) -> Path {
        var relativePath = String(self.string.trimmingPrefix(parentPath.string))
        if includeLeadingSlash && !relativePath.hasPrefix("/") {
            relativePath = "/\(relativePath)"
        }
        if !includeLeadingSlash && relativePath.hasPrefix("/") {
            relativePath.removeFirst()
        }
        return Path(relativePath)
    }
}


// MARK: File Metadata

extension Path {
    struct FileMetadata {
        typealias Bytes = Int64
        
        let dateAccessed: Date
        let dateModified: Date
        let dateStatusChanged: Date
        let dateCreated: Date
        
        let size: Bytes
    }
}

extension Path {
    var metadata: FileMetadata {
        get throws {
            var fileStat = stat()
            
            let result = stat(string, &fileStat)
            guard result == 0 else {
                throw CannotReadFileMetadata(path: string)
            }
            
            return FileMetadata(fileStat)
        }
    }
}

extension Path.FileMetadata {
    fileprivate init(_ stat: stat) {
        self.init(
            dateAccessed: Date(timeIntervalSince1970: Double(stat.st_atimespec.tv_sec)),
            dateModified: Date(timeIntervalSince1970: Double(stat.st_mtimespec.tv_sec)),
            dateStatusChanged: Date(timeIntervalSince1970: Double(stat.st_ctimespec.tv_sec)),
            dateCreated: Date(timeIntervalSince1970: Double(stat.st_birthtimespec.tv_sec)),
            size: stat.st_size
        )
    }
}


// MARK: Stencil

extension Path: Resolvable {
    public func resolve(_ context: Stencil.Context) throws -> Any? {
        string
    }
}


// MARK: Path Decoding

extension Path {
    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        switch self.url.pathExtension {
        case "toml":
            let decoder = TOMLDecoder()
            return try decoder.decode(type, from: self.read())
            
        case "json":
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: Data(contentsOf: self.url))
            
        default:
            throw UnsupportedConfigurationFileFormat(format: self.url.pathExtension, path: description)
        }
    }
}
