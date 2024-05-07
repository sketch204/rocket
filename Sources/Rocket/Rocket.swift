// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import PathKit
import RocketParsing
import TOMLKit

@main
struct Rocket: ParsableCommand {
    static let configFileName = "rocket.toml"
    
    var workingDirectory: Path {
        Path.current
    }
    
    var configFile: Path {
        workingDirectory + Path(Self.configFileName)
    }
    
    mutating func run() throws {
        let config = try loadConfig()
        
        let articleFileName = "article"
        let outputDirectoryName = "dist"
        
        let outputDirectory = workingDirectory + Path(outputDirectoryName)
        try outputDirectory.mkpath()
        
        let articleString = try String(
            contentsOf: (workingDirectory + Path("\(articleFileName).md")).url
        )
        
        var converter = HTMLConverter(
            markdown: articleString,
            templatesDirecotryPath: templatesPath(config: config)
        )
        let articleHtml = try converter.generateHTML()
        
        guard let articleData = articleHtml.data(using: .utf8) else {
            fatalError("Failed to parse string into data")
        }
        
        let articleOutputUrl = outputDirectory + Path("\(articleFileName).html")
        
        try articleData.write(to: articleOutputUrl.url, options: .atomic)
        
        print(workingDirectory)
        print(config)
        print("=== HTML ===")
        print(articleHtml)
    }
    
    func loadConfig() throws -> TOMLTable {
        try TOMLTable(
            string: String(contentsOf: configFile.url)
        )
    }
    
    func templatesPath(config: TOMLTable) -> Path? {
        config["templates_path"]?.string.map { workingDirectory + Path($0) }
    }
}
