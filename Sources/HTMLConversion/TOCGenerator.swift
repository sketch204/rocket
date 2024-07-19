import Foundation
import Markdown

// MARK: TOC Generator

/// Options given to the ``HTMLFormatter``.
public struct TOCGeneratorOptions: OptionSet {
    public var rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// When this flag is passed, all HTML reserved symbols will be replaced with
    public static let escapeHTMLReservedSymbols = Self(rawValue: 1 << 0)
}

extension TOCGeneratorOptions {
    public static let defaultOptions: Self = [.escapeHTMLReservedSymbols]
}

public enum TOCGenerator {
    public static func generate(from markup: Markup, options: TOCGeneratorOptions = .defaultOptions) -> TOC {
        var walker = _Generator(options: .defaultOptions)
        walker.visit(markup)
        return TOC(entries: walker.entries)
    }
    
    public static func generate(from inputString: String, options: TOCGeneratorOptions = .defaultOptions) -> TOC {
        let document = Document(parsing: inputString)
        return generate(from: document, options: options)
    }
}

extension TOCGenerator {
    private struct _Generator: MarkupWalker {
        let options: TOCGeneratorOptions
        
        private(set) var entries: [TOC.Entry] = []
        private var headingIdGenerator = HeadingIDGenerator()
        
        init(options: TOCGeneratorOptions = .defaultOptions) {
            self.options = options
        }
        
        mutating func visitHeading(_ heading: Heading) -> () {
            entries.append(
                TOC.Entry(
                    level: heading.level,
                    id: headingIdGenerator.generateHeadingId(from: htmlEncoded(heading.plainText)),
                    contents: heading.plainText
                )
            )
        }
        
        private func htmlEncoded(_ string: String) -> String {
            if options.contains(.escapeHTMLReservedSymbols) {
                string.htmlEncoded
            } else {
                string
            }
        }
    }
}


// MARK: TOC

public struct TOC: Hashable {
    public let entries: [Entry]
    
    public init(entries: [Entry]) {
        self.entries = entries
    }
}

extension TOC {
    public struct Entry: Hashable {
        public let level: Int
        public let id: String
        public let contents: String
        
        public init(level: Int, id: String, contents: String) {
            self.level = level
            self.id = id
            self.contents = contents
        }
    }
}

extension TOC {
    public struct Tree: Hashable {
        public var id: String
        public var contents: String
        public var children: [Tree]
        
        public init(id: String, contents: String, children: [Tree] = []) {
            self.id = id
            self.contents = contents
            self.children = children
        }
    }
}

extension TOC.Tree {
    public static func createTrees(from toc: TOC) -> [Self] {
        guard !toc.entries.isEmpty else { return [] }
        return createTree(entries: toc.entries, startIndex: 0, initialLevel: toc.entries.first!.level).trees
    }
    
    private static func createTree(entries: [TOC.Entry], startIndex: Int, initialLevel: Int) -> (trees: [Self], endIndex: Int) {
        var output = [TOC.Tree]()
        
        var skipUntilIndex: Int?
        
        for (index, entry) in entries.enumerated().dropFirst(startIndex) {
            if let skipUntilIndex, index < skipUntilIndex {
                continue
            }
            
            if entry.level > initialLevel {
                let (trees, endIndex) = createTree(entries: entries, startIndex: index, initialLevel: entry.level)
                skipUntilIndex = endIndex
                
                output[output.endIndex - 1].children = trees
            }
            else if entry.level < initialLevel {
                return (output, index)
            }
            else {
                output.append(
                    TOC.Tree(
                        id: entry.id,
                        contents: entry.contents
                    )
                )
            }
        }
        
        return (output, entries.endIndex)
    }
}
