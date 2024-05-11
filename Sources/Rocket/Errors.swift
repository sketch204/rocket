struct UnsupportedConfigurationFileFormat: Error, CustomStringConvertible {
    let format: String
    let path: String
    
    var description: String { "Found a configuration file in \"\(format)\" format, which is not supported" }
    var localizedDescription: String { description }
}

struct InvalidContext: Error, CustomStringConvertible {
    var description: String = ""
    var localizedDescription: String { description }
}

struct CannotReadFileMetadata: Error, CustomStringConvertible {
    let path: String
    
    var description: String { "Could not read file metadata at \(path)" }
    var localizedDescription: String { description }
}

struct MissingFrontMatterData: Error, CustomStringConvertible {
    let key: String
    let path: String
        
    var description: String { "Missing front matter value for \"\(key)\" at \(path)" }
    var localizedDescription: String { description }
}

struct InvalidFrontMatterDataType: Error, CustomStringConvertible {
    let key: String
    let expectedType: String
    let actualType: String
    let path: String
    
    var description: String { "Encountered invalid front matter value type for \(key) at \(path). Expected " }
    var localizedDescription: String { description }
}
