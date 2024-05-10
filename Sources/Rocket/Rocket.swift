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
        /*
         
         1. Build up a context
            1. Parse config file
            1. Parse all data files
            1. Parse posts
         2. Go through each html and md file in the site map
            1. Process front matter
            1. Inflate the file. Combine front matter with a global context
            1. If MD, convert to HTML
         3. Write generated files. All non-post file keep their original file structure. Asset paths are copied as is.
         
         */
        
        
        let config = try Config.loadDefault()
        let environment = createEnvironment(config: config)
        let globalContext = try Context.global(config: config)
        
        try copyAssets(config: config)
        
        let processablePaths = Path.allProcessableFilePaths(config: config)
        
        for path in processablePaths {
            let context = try Context.page(at: path, config: config)
            
            try processPage(context: context, globalContext: globalContext, environment: environment)
        }
    }
    
    private func createEnvironment(config: Config) -> Environment {
        Environment(
            loader: FileSystemLoader(
                paths: [ config.templatesPath, config.includesPath ]
            ),
            extensions: [
                SiteURL.makeExtension(with : config)
            ],
            trimBehaviour: .smart
        )
    }
    
    private func copyAssets(config: Config) throws {
        for path in config.assetsPaths {
            if path.isDirectory {
                let allSubPaths = path.iterateChildren()
                    .filter({ !$0.isDirectory })
                
                for path in allSubPaths {
                    try copyAssetPath(path, config: config)
                }
            }
            else {
                try copyAssetPath(path, config: config)
            }
        }
    }
    
    private func copyAssetPath(_ path: Path, config: Config) throws {
        let destinationPath = config.outputPath + path.relative(includeLeadingSlash: false)
        
        print("Copying asset at \(path)... ", terminator: "")
        
        try destinationPath.parent().normalize().mkpath()
        
        if destinationPath.exists {
            let isModified = try destinationPath.metadata.dateStatusChanged < path.metadata.dateModified
            
            if isModified {
                try destinationPath.delete()
            } else {
                print("❌ Aborting, file already exists!")
                return
            }
        }
        try path.copy(destinationPath.normalize())
        print("✅ Copied to \(destinationPath)!")
    }
}


extension Rocket {
    func processPage(context: Context, globalContext: Context, environment: Environment) throws {
        guard let inputPath = context[.inputPath] as? Path,
              let outputPath = context[.absoluteOutputPath] as? Path
        else { throw InvalidContext(localizedDescription: "Input or output paths missing") }
        
        print("Processing file at \(inputPath)")
        
        var pageContext = globalContext
        pageContext["page"] = context.dictionary
        
        var pageContents: String = try inputPath.read()
        
        pageContents = try parsePage(pageContents, context: pageContext, environment: environment)
        
        switch inputPath.extension?.lowercased() {
        case "md":
            pageContents = HTMLConverter.convert(markdown: pageContents)
            
        default: break
        }
        
        // Generate output directory
        try outputPath.parent().normalize().mkpath()
        try outputPath.write(pageContents, encoding: .utf8)
    }
    
    private func parsePage(
        _ pageContents: String,
        context: Context,
        environment: Environment
    ) throws -> String {
        let pageContents = FrontMatter.removeFrontmatter(from: pageContents)
        
        let templatedString = insertTemplateTags(to: pageContents, context: context)
        
        let pageTemplate = Template(templateString: templatedString, environment: environment)
        let inflatedPageContents = try pageTemplate.render(
            Stencil.Context(
                dictionary: context.dictionary,
                environment: environment
            )
        )
        
        return inflatedPageContents
    }
    
    private func insertTemplateTags(to contents: String, context: Context) -> String {
        if let pageContext = context["page"] as? [String: Any], var layoutName = pageContext["layout"] as? String {
            let layoutBlockName = pageContext["layoutBlockName"] as? String ?? "content"
            
            if !layoutName.contains(".") {
                layoutName = "\(layoutName).html"
            }
            
            return """
            {% extends "\(layoutName)" %}
            {% block \(layoutBlockName) %}
            \(contents)
            {% endblock %}
            """
        }
        else {
            return contents
        }
    }
}
