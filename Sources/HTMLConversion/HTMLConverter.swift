import Markdown
import Stencil
import PathKit
import RegexBuilder

public enum HTMLConverter {
    private static let doctypeRegex = Regex {
        "<!doctype html>"
    }
    .ignoresCase()
    
    public static func convert(markdown: String) -> String {
        if startWithDocTypePrefix(markdown) {
            let markdown = removeDocTypePrefix(from: markdown)
            let html = convertToHTML(markdown)
            let output = addDocTypePrefix(to: html)
            return output
        } 
        else {
            return convertToHTML(markdown)
        }
    }
    
    private static func convertToHTML(_ markdown: String) -> String {
        HTMLFormatter.format(
            Document(parsing: markdown, options: [.disableSmartOpts])
        )
    }
    
    private static func startWithDocTypePrefix(_ markdown: String) -> Bool {
        markdown.prefixMatch(of: doctypeRegex) != nil
    }
    
    private static func removeDocTypePrefix(from markdown: String) -> String {
        String(markdown.trimmingPrefix(doctypeRegex))
    }
    
    private static func addDocTypePrefix(to markdown: String) -> String {
        "<!DOCTYPE html>\n" + markdown
    }
}
