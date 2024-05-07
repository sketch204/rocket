// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import RocketParsing
import TOMLKit

@main
struct Rocket: ParsableCommand {
    var workingDirectoryUrl: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
    
    var configFileUrl: URL {
        workingDirectoryUrl.appending(path: ".rocket.toml")
    }
    
    mutating func run() throws {
        let config = try loadConfig()
        
        let articleFileName = "article"
        let outputDirectory = "dist"
        
        let outputDirectoryUrl = workingDirectoryUrl
            .appending(path: outputDirectory, directoryHint: .isDirectory)
        
        try createDirectoryIfNeeded(at: outputDirectoryUrl)
        
        let articleString = try String(
            contentsOf: workingDirectoryUrl
                .appending(path: articleFileName)
                .appendingPathExtension("md")
        )
        
        var converter = HTMLConverter(
            markdown: articleString,
            templatesDirecotryPath: templatesPath(config: config)
        )
        let articleHtml = try converter.generateHTML()
        
        guard let articleData = articleHtml.data(using: .utf8) else {
            fatalError("Failed to parse string into data")
        }
        
        let articleOutputUrl = outputDirectoryUrl
            .appending(path: articleFileName)
            .appendingPathExtension("html")
        
        try articleData.write(to: articleOutputUrl, options: .atomic)
        
        print(FileManager.default.currentDirectoryPath)
        print(config)
        print("=== HTML ===")
        print(articleHtml)
    }
    
    func loadConfig() throws -> TOMLTable {
        try TOMLTable(
            string: String(contentsOf: configFileUrl)
        )
    }
    
    func templatesPath(config: TOMLTable) -> String? {
        config["templates_path"]?.string.map { "\(workingDirectoryUrl.path())\($0)" }
    }
    
    func createDirectoryIfNeeded(at url: URL) throws {
        let fm = FileManager.default
        
        try fm.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
