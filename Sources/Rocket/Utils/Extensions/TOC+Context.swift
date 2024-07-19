import HTMLConversion

extension TOC {
    var contextRepresentation: [[String: Any]] {
        entries.map { entry in
            [
                "contents": entry.contents,
                "level": entry.level,
                "id": entry.id,
            ]
        }
    }
}

extension TOC {
    init?(pageContext: Context) {
        guard let context = pageContext.context(.page)?[.tableOfContents] as? [[String: Any]] else {
            return nil
        }
        self.init(context)
    }
    
    fileprivate init(_ rawValue: [[String: Any]]) {
        self.init(entries: rawValue.compactMap(TOC.Entry.init))
    }
}

extension TOC.Entry {
    fileprivate init?(_ dictionary: [String: Any]) {
        guard let contents = dictionary["contents"] as? String,
              let level = dictionary["level"] as? Int,
              let id = dictionary["id"] as? String
        else { return nil }
        
        self.init(level: level, id: id, contents: contents)
    }
}
