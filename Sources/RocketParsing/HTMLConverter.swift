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
        
        let document = Document(parsing: markdown, options: [.disableSmartOpts])
        
        return HTMLFormatter.format(document)
    }
}
