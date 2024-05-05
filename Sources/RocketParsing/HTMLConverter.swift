import Markdown
import Stencil

public struct HTMLConverter {
    public let markdown: String
    public var documentContext: [String: String] = [:]
    
    internal let environment = Environment()
    
    public init(markdown: String, documentContext: [String : String] = [:]) {
        self.markdown = markdown
        self.documentContext = documentContext
    }
    
    public mutating func generateHTML() throws -> String {
        let frontmatter = parseFrontmatter(from: markdown)
        
        documentContext.merge(frontmatter, uniquingKeysWith: { $1 })
        
        var markdown = removeFrontmatter(from: markdown)
        
        markdown = try environment.renderTemplate(string: markdown, context: documentContext)
        
        let document = Document(parsing: markdown, options: [.parseBlockDirectives])
        
        return visit(document)
    }
}


extension HTMLConverter: MarkupVisitor {
    private mutating func defaultDescend(_ markup: any Markup) -> String {
        if markup.childCount == 0 {
            if let markup = markup as? InlineCode {
                markup.code
            } else {
                (markup as? Text).map({ $0.string }) ?? ""
            }
        } else {
            markup.children.map({ visit($0) }).joined()
        }
    }
    
    public mutating func defaultVisit(_ markup: any Markup) -> String {
        if let element = markup as? HTMLConvertable {
            return element.rawHTML(defaultDescend(markup))
        } else {
            return defaultDescend(markup)
        }
    }
}
