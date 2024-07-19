import Foundation
import Markdown

/// Options given to the ``HTMLFormatter``.
public struct HTMLFormatterOptions: OptionSet {
    public var rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Attempt to parse blockquotes as asides.
    ///
    /// If a blockquote is found to begin with an aside marker, e.g. "`Remark:`" then the
    /// corresponding HTML will be an `<aside>` tag instead of a `<blockquote>` tag, with the aside
    /// kind given in the `data-kind` attribute.
    ///
    /// - Note: To prevent false positives, the aside checking will only look for a single-word
    ///   aside marker, i.e. the following blockquote will not parse as an aside:
    ///
    ///   ```markdown
    ///   > This is a compound sentence: It contains two clauses separated by a colon.
    ///   ```
    public static let parseAsides = HTMLFormatterOptions(rawValue: 1 << 0)

    /// Parse inline attributes as JSON and use the `"class"` property as the resulting span's `class`.
    public static let parseInlineAttributeClass = HTMLFormatterOptions(rawValue: 1 << 1)
    
    public static let escapeHTMLReservedSymbols = HTMLFormatterOptions(rawValue: 1 << 2)
    
    public static let injectAsideTitles = HTMLFormatterOptions(rawValue: 1 << 3)
    
    /// When this option is enabled, all headings will have their ID field populated with the heading's simplified contents.
    public static let generateHeadingIDs = HTMLFormatterOptions(rawValue: 1 << 4)
}

extension HTMLFormatterOptions {
    public static let defaultOptions: HTMLFormatterOptions = [.parseAsides, .parseInlineAttributeClass, escapeHTMLReservedSymbols, .injectAsideTitles, .generateHeadingIDs]
}

/// A ``MarkupWalker`` that prints rendered HTML for a given ``Markup`` tree.
struct HTMLFormatter: MarkupWalker {
    /// The resulting HTML built up after printing.
    private(set) var result = ""

    let options: HTMLFormatterOptions

    private var inTableHead = false
    private var tableColumnAlignments: [Table.ColumnAlignment?]? = nil
    private var currentTableColumn = 0
    private var headingIdGenerator = HeadingIDGenerator()

    init(options: HTMLFormatterOptions = .defaultOptions) {
        self.options = options
    }

    /// Format HTML for the given markup tree.
    static func format(_ markup: Markup, options: HTMLFormatterOptions = .defaultOptions) -> String {
        var walker = HTMLFormatter(options: options)
        walker.visit(markup)
        return walker.result
    }

    /// Format HTML for the given input text.
    static func format(_ inputString: String, options: HTMLFormatterOptions = .defaultOptions) -> String {
        let document = Document(parsing: inputString)
        return format(document, options: options)
    }

    // MARK: Block elements

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> () {
        if blockQuote.isAside() {
            let aside = Aside(blockQuote)
            let asideKind = htmlEncoded(aside.kind.rawValue)
            result += "<aside data-kind=\"\(asideKind.lowercased())\">\n"
            if options.contains(.injectAsideTitles) {
                result += "<h1>\(asideKind.capitalized)</h1>"
            }
            for child in aside.content {
                visit(child)
            }
            result += "</aside>\n"
        } else {
            result += "<blockquote>\n"
            descendInto(blockQuote)
            result += "</blockquote>\n"
        }
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
        let languageAttr: String
        if let language = codeBlock.language {
            languageAttr = " class=\"language-\(htmlEncoded(language.lowercased()))\""
        } else {
            languageAttr = ""
        }
        result += "<pre><code\(languageAttr)>\(htmlEncoded(codeBlock.code))</code></pre>\n"
    }

    mutating func visitHeading(_ heading: Heading) {
        var attributes = [String: String]()
        if options.contains(.generateHeadingIDs) {
            attributes["id"] = headingIdGenerator.generateHeadingId(from: htmlEncoded(heading.plainText))
        }
        printInline(tag: "h\(heading.level)", attributes: attributes, content: htmlEncoded(heading.plainText))
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
        result += "<hr />\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> () {
        result += html.rawHTML
    }

    mutating func visitListItem(_ listItem: ListItem) -> () {
        result += "<li>"
        if let checkbox = listItem.checkbox {
            result += "<input type=\"checkbox\" disabled=\"\""
            if checkbox == .checked {
                result += " checked=\"\""
            }
            result += " /> "
        }
        descendInto(listItem)
        result += "</li>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> () {
        let start: String
        if orderedList.startIndex != 1 {
            start = " start=\"\(orderedList.startIndex)\""
        } else {
            start = ""
        }
        result += "<ol\(start)>\n"
        descendInto(orderedList)
        result += "</ol>\n"
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> () {
        result += "<ul>\n"
        descendInto(unorderedList)
        result += "</ul>\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> () {
        result += "<p>"
        descendInto(paragraph)
        result += "</p>"
    }

    mutating func visitTable(_ table: Table) -> () {
        result += "<table>\n"
        tableColumnAlignments = table.columnAlignments
        descendInto(table)
        tableColumnAlignments = nil
        result += "</table>\n"
    }

    mutating func visitTableHead(_ tableHead: Table.Head) -> () {
        result += "<thead>\n"
        result += "<tr>\n"

        inTableHead = true
        currentTableColumn = 0
        descendInto(tableHead)
        inTableHead = false

        result += "</tr>\n"
        result += "</thead>\n"
    }

    mutating func visitTableBody(_ tableBody: Table.Body) -> () {
        if !tableBody.isEmpty {
            result += "<tbody>\n"
            descendInto(tableBody)
            result += "</tbody>\n"
        }
    }

    mutating func visitTableRow(_ tableRow: Table.Row) -> () {
        result += "<tr>\n"

        currentTableColumn = 0
        descendInto(tableRow)

        result += "</tr>\n"
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) -> () {
        guard let alignments = tableColumnAlignments, currentTableColumn < alignments.count else { return }

        guard tableCell.colspan > 0 && tableCell.rowspan > 0 else { return }

        let element: String
        if inTableHead {
            element = "th"
        } else {
            element = "td"
        }

        if inTableHead {
            result += "<\(element)"
        } else {
            result += "<\(element)"
        }

        if let alignment = alignments[currentTableColumn] {
            result += " align=\"\(alignment)\""
        }
        currentTableColumn += 1

        if tableCell.rowspan > 1 {
            result += " rowspan=\"\(tableCell.rowspan)\""
        }
        if tableCell.colspan > 1 {
            result += " colspan=\"\(tableCell.colspan)\""
        }

        result += ">"

        descendInto(tableCell)

        result += "</\(element)>\n"
    }

    // MARK: Inline elements

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> () {
        printInline(tag: "code", content: inlineCode.code)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> () {
        printInline(tag: "em", emphasis)
    }

    mutating func visitStrong(_ strong: Strong) -> () {
        printInline(tag: "strong", strong)
    }

    mutating func visitImage(_ image: Image) -> () {
        result += "<img"

        if let source = image.source {
            result += " src=\"\(htmlEncoded(source))\""
        }

        if let title = image.title {
            result += " title=\"\(htmlEncoded(title))\""
        }

        result += " />"
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> () {
        result += inlineHTML.rawHTML
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> () {
        result += "<br />\n"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> () {
        result += "\n"
    }

    mutating func visitLink(_ link: Link) -> () {
        result += "<a"
        if let destination = link.destination {
            result += " href=\"\(htmlEncoded(destination))\""
        }
        result += ">"

        descendInto(link)

        result += "</a>"
    }

    mutating func visitText(_ text: Text) -> () {
        result += htmlEncoded(text.string)
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> () {
        printInline(tag: "del", strikethrough)
    }

    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> () {
        if let destination = symbolLink.destination {
            printInline(tag: "code", content: destination)
        }
    }

    mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> () {
        result += "<span data-attributes=\"\(htmlEncoded(attributes.attributes))\""

        let wrappedAttributes = "{\(attributes.attributes)}"
        if options.contains(.parseInlineAttributeClass),
           let attributesData = wrappedAttributes.data(using: .utf8)
        {
            struct ParsedAttributes: Decodable {
                var `class`: String
            }

            let decoder = JSONDecoder()
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                decoder.allowsJSON5 = true
            }
            #endif

            let parsedAttributes = try? decoder.decode(ParsedAttributes.self, from: attributesData)
            if let parsedAttributes = parsedAttributes {
                result += " class=\"\(htmlEncoded(parsedAttributes.class))\""
            }
        }

        result += ">"
        descendInto(attributes)
        result += "</span>"
    }
    
    
    // MARK: Misc
    
    private func htmlEncoded(_ string: String) -> String {
        if options.contains(.escapeHTMLReservedSymbols) {
            string.htmlEncoded
        } else {
            string
        }
    }
    
    private mutating func printInline(tag: String, attributes: [String: String] = [:], content: String) {
        let attributeString = if attributes.isEmpty {
            ""
        } else {
            " " + attributeHtmlString(attributes: attributes)
        }
        result += "<\(tag)\(attributeString)>\(htmlEncoded(content))</\(tag)>"
    }
    
    private func attributeHtmlString(attributes: [String: String]) -> String {
        attributes.map { (key: String, value: String) in
            "\(htmlEncoded(key))=\"\(htmlEncoded(value))\""
        }
        .joined(separator: " ")
    }

    private mutating func printInline(tag: String, _ inline: InlineMarkup) {
        printInline(tag: tag, content: inline.plainText)
    }
}
