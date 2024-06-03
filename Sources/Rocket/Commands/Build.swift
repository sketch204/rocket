import ArgumentParser
import Foundation
import FrontMatterKit
import PathKit
import HTMLConversion
import Stencil
import TOMLKit

extension Rocket {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Build the website")
        
        @Option(
            name: [.short, .customLong("config")],
            help: "A path to a custom config file",
            completion: .file(extensions: ["toml", "json", "yaml", "yml"]),
            transform: { Path.current + Path($0) }
        )
        var configPath: Path?
        
        mutating func run() throws {
            let config = if let configPath {
                try Config(path: configPath)
            } else {
                try Config.loadDefault()
            }
            
            var extensions = [Extension]()
            extensions.append(contentsOf: CustomFilters.extensions(config: config))
            extensions.append(contentsOf: CustomTags.extensions(config: config))
            
            let environment = Environment(
                loader: FileSystemLoader(
                    paths: [ config.templatesPath, config.includesPath ]
                ),
                extensions: extensions,
                trimBehaviour: .smart
            )
            
            let globalContext = try Context.global(config: config)
            
            try copyAssets(config: config)
            
            let processablePaths = Path.allProcessableFilePaths(config: config)
            
            for path in processablePaths {
                let context = try Context.page(
                    at: path,
                    config: config,
                    postContexts: globalContext.contexts(.posts) ?? []
                )
                
                try processPage(context: context, globalContext: globalContext, environment: environment)
            }
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
}


extension Rocket.Build {
    private func processPage(context: Context, globalContext: Context, environment: Environment) throws {
        guard let inputPath = context[.inputPath] as? Path,
              let outputPath = context[.absoluteOutputPath] as? Path
        else { throw InvalidContext(description: "Input or output paths missing") }
        
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
        if let pageContext = context.context(.page),
            var layoutName = pageContext[.layout] as? String
        {
            let layoutBlockName = pageContext[.layoutBlockName] as? String ?? "content"
            
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
