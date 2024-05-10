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
