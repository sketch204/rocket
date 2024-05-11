import DecodingUtils
import Foundation
import RegexBuilder
import TOMLKit

public struct FrontMatter {
    public let dictionary: [String: Any]
    
    public init(dictionary: [String : Any] = [:]) {
        self.dictionary = dictionary
    }
}

extension FrontMatter {
    fileprivate static let argumentTextRef = Reference(Substring.self)

    fileprivate static let frontmatterRegex = Regex {
        Anchor.startOfSubject
        
        "+++"
        
        CharacterClass.newlineSequence
        
        Capture(as: argumentTextRef) {
            ZeroOrMore(.reluctant) {
                CharacterClass.any
            }
        }
        
        "+++"
        
        Optionally(CharacterClass.newlineSequence)
    }
}

extension FrontMatter {
    struct ArgumentContainer: Decodable {
        let arguments: [String: Any]
        
        init(from decoder: any Decoder) throws {
            self.arguments = try Dictionary(from: decoder)
        }
    }
    
    public init(from markdown: String) throws {
        if let match = markdown.prefixMatch(of: Self.frontmatterRegex) {
            let argumentText = String(match[Self.argumentTextRef])
            
            let arguments = try TOMLDecoder().decode(ArgumentContainer.self, from: argumentText)
            
            self.dictionary = arguments.arguments
        } else {
            self.dictionary = [:]
        }
    }

    public static func removeFrontmatter(from markdown: String) -> String {
        String(markdown.trimmingPrefix(frontmatterRegex))
    }
}

extension FrontMatter {
    public subscript(_ key: String) -> Any? {
        dictionary[key]
    }
}
