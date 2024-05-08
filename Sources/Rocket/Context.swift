import FrontMatterKit
import PathKit

struct Context {
    var dictionary: [String: Any]
}

extension Context: Decodable {
    init(from decoder: any Decoder) throws {
        self.dictionary = try Dictionary(from: decoder)
    }
    
    init(from path: Path) throws {
        self = try path.decode(Self.self)
    }
}

extension Context {
    init(frontMatter: FrontMatter) {
        self.init(dictionary: frontMatter.dictionary)
    }
    
    static func page(at path: Path) throws -> Self {
        page(try path.read())
    }
    
    static func page(_ contents: String) -> Self {
        let frontMatter = FrontMatter(from: contents)
        return Self(frontMatter: frontMatter)
    }
}
