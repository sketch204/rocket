struct UnsupportedConfigurationFileFormat: Error {
    let format: String
    let path: String
    
    var localizedDescription: String {
        "Found a configuration file in \"\(format)\" format, which is not supported"
    }
}

struct InvalidContext: Error {
    var localizedDescription: String = ""
}

struct CannotReadFileMetadata: Error {
    let path: String
    
    var localizedDescription: String {
        "Could not read file metadata at \(path)"
    }
}

struct MissingFrontMatterData: Error {
    let key: String
    let path: String
    
    var localizedDescription: String {
        "Missing front matter value for \(key) at \(path)"
    }
}

struct InvalidFrontMatterDataType: Error {
    let key: String
    let expectedType: String
    let actualType: String
    let path: String
    
    var localizedDescription: String {
        "Encountered invalid front matter value type for \(key) at \(path). Expected "
    }
}
