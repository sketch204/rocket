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
    var workingDirectory: Path {
        Path.current
    }
    
    mutating func run() throws {
        let config = try Config.loadDefault()
        
        let articleFileName = "posts/2023-09-07-how-to-use-tables-in-swiftui"
        let outputDirectoryName = "dist"
        
        let outputDirectory = workingDirectory + Path(outputDirectoryName)
        try outputDirectory.mkpath()
        
        let articleString = try String(
            contentsOf: (workingDirectory + Path("\(articleFileName).md")).url
        )
        
        var converter = HTMLConverter(
            markdown: articleString,
            templatesDirecotryPath: config.templatesPath
        )
        let articleHtml = try converter.generateHTML()
        
        guard let articleData = articleHtml.data(using: .utf8) else {
            fatalError("Failed to parse string into data")
        }
        
        let articleOutputPath = outputDirectory + Path("\(articleFileName).html")
        
        print("About to write to \(articleOutputPath)")
        
        try articleData.write(to: articleOutputPath.url, options: .atomic)
        
        print(workingDirectory)
        print(config)
        print("=== HTML ===")
        print(articleHtml)
    }
}
