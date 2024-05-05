public protocol HTMLConvertable {
    var htmlTag: String { get }
    var attributes: [String: String] { get }
    var isSelfClosing: Bool { get }
    
    func rawHTML(_ content: String) -> String
}

extension HTMLConvertable {
    public var htmlTag: String { "" }
    
    public var attributes: [String: String] { [:] }
    
    public var isSelfClosing: Bool {
        switch htmlTag {
        case "br", "col", "hr", "img", "link", "meta": true
        default: false
        }
    }
    
    public func rawHTML(_ content: String) -> String {
        guard !htmlTag.isEmpty else { return content }
        guard !isSelfClosing else { return "<\(htmlTag)/>" }
        
        let attributesString = if attributes.isEmpty { "" } else {
            " " + attributes.map({ "\($0)=\"\($1)\"" }).joined(separator: " ")
        }
        
        return "<\(htmlTag)\(attributesString)>\(content)</\(htmlTag)>"
    }
}
