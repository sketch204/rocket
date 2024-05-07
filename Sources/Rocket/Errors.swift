struct ConfigFileNotFound: Error {
    let localizedDescription = "No .rocket.toml file found"
}
