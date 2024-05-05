import Markdown

struct HTMLConverter {
    let markdown: String
    
    var documentContext: [String: String] = [:]
    
    mutating func generateHTML() -> String {
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
    
    mutating func defaultVisit(_ markup: any Markup) -> String {
        if let element = markup as? HTMLConvertable {
            return element.rawHTML(defaultDescend(markup))
        } else {
            return defaultDescend(markup)
        }
    }
    
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> String {
        switch blockDirective.name {
        case "Meta":
            let arguments = blockDirective.argumentText.parseNameValueArguments()
            print("Metadata: \(arguments.map({ "\($0.name): \($0.value)" }))")
            
            for argument in arguments {
                documentContext[argument.name] = argument.value
            }
            
            return ""
            
        default: return ""
        }
    }
}
