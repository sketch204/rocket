import Markdown

extension Document: HTMLConvertable {
    public var htmlTag: String { "body" }
}


// MARK: - Block

extension BlockQuote: HTMLConvertable {
    public var htmlTag: String { "blockquote" }
}

extension Heading: HTMLConvertable {
    public var htmlTag: String { "h\(level)" }
}

extension Paragraph: HTMLConvertable {
    public var htmlTag: String { "p" }
}

extension CodeBlock: HTMLConvertable {
    public func rawHTML(_ content: String) -> String {
        let languageClass = language.map({ " class=\"lang-\($0.lowercased())\"" }) ?? ""
        
        return """
        <pre><code\(languageClass)>
        \(code.trimmingCharacters(in: .newlines).htmlEncoded)
        </code></pre>
        """
    }
}

extension HTMLBlock: HTMLConvertable {
    public func rawHTML(_ content: String) -> String {
        rawHTML
    }
}

extension Aside: HTMLConvertable {
    public var htmlTag: String { "aside" }
    public var attributes: [String : String] {
        ["class": kind.rawValue]
    }
}

// MARK: List

extension UnorderedList: HTMLConvertable {
    public var htmlTag: String { "ul" }
}

extension OrderedList: HTMLConvertable {
    public var htmlTag: String { "ol" }
}

extension ListItem: HTMLConvertable {
    public var htmlTag: String { "li" }
}


// MARK: - Inline

extension Emphasis: HTMLConvertable {
    public var htmlTag: String { "em" }
}

extension Strong: HTMLConvertable {
    public var htmlTag: String { "strong" }
}

extension Strikethrough: HTMLConvertable {
    public var htmlTag: String { "s" }
}

extension Image: HTMLConvertable {
    public var htmlTag: String { "img" }
    public var attributes: [String : String] {
        ["src": source ?? ""]
    }
}

extension Link: HTMLConvertable {
    public var htmlTag: String { "a" }
    public var attributes: [String : String] {
        ["href": destination ?? ""]
    }
}

extension InlineCode: HTMLConvertable {
    public var htmlTag: String { "code" }
}

extension InlineHTML: HTMLConvertable {
    public func rawHTML(_ content: String) -> String {
        rawHTML
    }
}

extension LineBreak: HTMLConvertable {
    public var htmlTag: String { "hr" }
}

extension SoftBreak: HTMLConvertable {
    public var htmlTag: String { "br" }
}
