import DecodingUtils
import Foundation
import FrontMatterKit
import PathKit

struct Context {
    var dictionary: [String: Any] = [:]
}

extension Context: Decodable {
    init(from decoder: any Decoder) throws {
        self.dictionary = try Dictionary(from: decoder)
    }
    
    init(from path: Path) throws {
        self = try path.decode(Self.self)
    }
}

extension Context {
    subscript(_ key: String) -> Any? {
        get { dictionary[key] }
        set { dictionary[key] = newValue }
    }
    
    subscript(_ key: Key) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
    
    func context(_ key: String) -> Context? {
        guard let dictionary = self[key] as? [String: Any] else { return nil }
        return Context(dictionary: dictionary)
    }
    
    func context(_ key: Key) -> Context? {
        context(key.rawValue)
    }
}

extension Context {
    mutating func merge(with dictionary: [String: Any], keySelector: (Any, Any) -> Any = { $1 }) {
        self.dictionary.merge(dictionary, uniquingKeysWith: keySelector)
    }
    
    mutating func merge(with context: Context, keySelector: (Any, Any) -> Any = { $1 }) {
        merge(with: context.dictionary, keySelector: keySelector)
    }
    
    mutating func merge(with frontMatter: FrontMatter, keySelector: (Any, Any) -> Any = { $1 }) {
        merge(with: frontMatter.dictionary, keySelector: keySelector)
    }
}


// MARK: Global

extension Context {
    static func global(config: Config) throws -> Self {
        print("Assembling global context")
        let dataContexts: [String: Any] = try allDataContexts(config: config)
            .mapValues(\.dictionary)
        let postsContext: [String: Any] = [
            "posts": try posts(config: config).map(\.dictionary)
        ]
        
        return Context(
            dictionary: dataContexts.merging(postsContext, uniquingKeysWith: { $1 })
        )
    }
    
    static func allDataContexts(config: Config) throws -> [String: Self] {
        try Path.allDataFilePaths(config: config)
            .reduce(into: [String: Context]()) { output, path in
                output[path.lastComponentWithoutExtension] = try Context.data(at: path)
            }
    }
    
    static func posts(config: Config) throws -> [Self] {
        let output = try Path.allPostPaths(config: config)
            .map { path in
                try page(at: path, config: config)
            }
        
        for post in output {
            if post[.date] == nil {
                throw MissingFrontMatterData(key: Context.Key.date.rawValue, path: (post[.inputPath] as? Path)?.string ?? "unknown path")
            }
            else if !(post[.date] is Date) {
                throw InvalidFrontMatterDataType(
                    key: Context.Key.date.rawValue,
                    expectedType: String(describing: Date.self),
                    actualType: String(describing: type(of: post[.date])),
                    path: (post[.inputPath] as? Path)?.string ?? "unknown path"
                )
            }
        }
        
        return output.sorted { c1, c2 in
            guard let date1 = c1[.date] as? Date, let date2 = c2[.date] as? Date else {
                return true
            }
            
            return date1 > date2
        }
    }
}


// MARK: Page

extension Context {
    init(frontMatter: FrontMatter) {
        self.init(dictionary: frontMatter.dictionary)
    }
    
    static func page(at path: Path, config: Config) throws -> Self {
        print("Assmebling context for page at \(path)")
        var output = self.defaults(for: path, config: config)
        
        output.merge(with: try page(path.read()))
        output[.inputPath] = path
        
        let outputPath = outputPath(for: path, config: config)
        
        output[.absoluteOutputPath] = outputPath
        output[.outputPath] = outputPath.relative(to: config.outputPath)
        output[.filename] = outputPath.lastComponent
        output[.filenameWithoutExtension] = outputPath.lastComponentWithoutExtension
        
        return output
    }
    
    static func page(_ contents: String) throws -> Self {
        let frontMatter = try FrontMatter(from: contents)
        return Self(frontMatter: frontMatter)
    }
    
    static func defaults(for path: Path, config: Config) -> Context {
        guard let values = config.defaults.first(where: { path.matchesDirectory($0.path) })?.values else {
            return Context()
        }
        return Context(dictionary: values)
    }
    
    private static func outputPath(for path: Path, config: Config) -> Path {
        var relativePath = String(path.string.trimmingPrefix(Path.current.string))
        if relativePath.hasPrefix("/") {
            relativePath = String(relativePath.dropFirst())
        }
        let destinationPath = config.outputPath + relativePath
        
        return (destinationPath.parent() + "\(destinationPath.lastComponentWithoutExtension).html").normalize()
    }
}


// MARK: Data

extension Context {
    static func data(at path: Path) throws -> Self {
        try path.decode(Self.self)
    }
}


// MARK: Key

extension Context {
    struct Key: RawRepresentable {
        var rawValue: String
    }
}

extension Context.Key {
    static let page = Self(rawValue: "page")
    
    static let inputPath = Self(rawValue: "inputPath")
    static let absoluteOutputPath = Self(rawValue: "absoluteOutputPath")
    
    static let outputPath = Self(rawValue: "outputPath")
    static let filename = Self(rawValue: "filename")
    static let filenameWithoutExtension = Self(rawValue: "filenameWithoutExtension")
    
    static let layout = Self(rawValue: "layout")
    static let layoutBlockName = Self(rawValue: "layoutBlockName")
    
    static let date = Self(rawValue: "date")
}
