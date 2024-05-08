// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import FrontMatterKit
import PathKit
import HTMLConversion
import Stencil
import TOMLKit

@main
struct Rocket: ParsableCommand {
    var workingDirectory: Path {
        Path.current
    }
    
    mutating func run() throws {
        let config = try Config.loadDefault()
        let environment = Environment(
            loader: FileSystemLoader(
                paths: [ config.templatesPath, config.includesPath ]
            ),
            trimBehaviour: .smart
        )
        
        let articleFileName = "posts/2023-09-07-how-to-use-tables-in-swiftui"
        let outputDirectoryName = "dist"
        
        // Generate output directory
        let outputDirectory = workingDirectory + Path(outputDirectoryName)
        try outputDirectory.mkpath()
        
        // Load article
        let articlePath = workingDirectory + Path("\(articleFileName).md")
        var articleString = try String(
            contentsOf: articlePath.url
        )
        
        // Parse front matter
        let articleContext = Context.page(articleString)
        articleString = FrontMatter.removeFrontmatter(from: articleString)
        
        // Inflate templating
        let template = Template(templateString: articleString, environment: environment)
        let inflatedArticleString = try template.render(
            Stencil.Context(
                dictionary: ["page": articleContext.dictionary],
                environment: environment
            )
        )
        
        // Convert to HTML
        let articleHtml = HTMLConverter.convert(markdown: inflatedArticleString)
        
        // Save to disk
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
