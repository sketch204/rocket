struct UnsupportedConfigurationFileFormat: Error {
    let format: String
    
    var localizedError: String {
        "Found a configuration file in \"\(format)\" format, which is not supported"
    }
}
