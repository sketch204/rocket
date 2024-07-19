import Foundation
import HTMLConversion
import Stencil

extension CustomTags {
    struct TableOfContents {
        static func makeExtension(with config: Config) -> Extension {
            let ext = Extension()
            
            ext.registerSimpleTag("table_of_contents") { context in
                generateContent(with: config, context: Context(dictionary: context.flatten()))
            }
            return ext
        }
        
        static func generateContent(with config: Config, context: Context) -> String {
            guard let toc = TOC(pageContext: context), !toc.entries.isEmpty else {
                return ""
            }
            
            let trees = TOC.Tree.createTrees(from: toc)
            
            return generateTableOfContents(for: trees)
        }
        
        static func generateTableOfContents(for trees: [TOC.Tree]) -> String {
            guard !trees.isEmpty else { return "" }
            
            var output = "<ul>\n"
            for tree in trees {
                output += "<li><a href=\"#\(tree.id)\">\(tree.contents)</a>"
                output += generateTableOfContents(for: tree.children)
                output += "</li>\n"
            }
            output += "</ul>"
            return output
        }
    }
}
