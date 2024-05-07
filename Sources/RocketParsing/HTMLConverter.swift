import Markdown
import Stencil
import PathKit

public struct HTMLConverter {
    public let markdown: String
    public var documentContext: [String: String] = [:]
    
    internal let environment: Environment
    
    public init(markdown: String, templatesDirecotryPath: String? = nil, documentContext: [String : String] = [:]) {
        self.markdown = markdown
        self.documentContext = documentContext
        self.environment = Environment(
            loader: FileSystemLoader(
                paths: templatesDirecotryPath.map({ [Path($0)] }) ?? []
            )
        )
    }
    
    public mutating func generateHTML() throws -> String {
        extractFrontMatter(from: markdown)
        
        var markdown = removeFrontmatter(from: markdown)
        
        markdown = try inflate(markdown)
        
        markdown = removeDocTypePrefix(from: markdown)
        
        var html = convertToHTML(markdown)
        
        html = addDocTypePrefix(to: html)
        
        return html
    }
    
    private mutating func extractFrontMatter(from markdown: String) {
        let frontmatter = parseFrontmatter(from: markdown)
        documentContext.merge(frontmatter, uniquingKeysWith: { $1 })
    }
    
    private func inflate(_ markdown: String) throws -> String {
        try environment.renderTemplate(string: markdown, context: documentContext).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func convertToHTML(_ markdown: String) -> String {
        HTMLFormatter.format(
            Document(parsing: markdown, options: [.disableSmartOpts])
        )
    }
    
    private func removeDocTypePrefix(from markdown: String) -> String {
        let regex = Regex {
            "<!doctype html>"
        }
        .ignoresCase()
        
        return String(markdown.trimmingPrefix(regex))
    }
    
    private func addDocTypePrefix(to markdown: String) -> String {
        "<!DOCTYPE html>\n" + markdown
    }
}
