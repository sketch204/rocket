import Foundation
import RegexBuilder

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
        
        "---"
        
        CharacterClass.newlineSequence
        
        Capture(as: argumentTextRef) {
            ZeroOrMore(.reluctant) {
                CharacterClass.any
            }
        }
        
        "---"
        
        Optionally(CharacterClass.newlineSequence)
    }
}

extension FrontMatter {
    public init(from markdown: String) {
        if let match = markdown.prefixMatch(of: Self.frontmatterRegex) {
            
            let argumentText = String(match[Self.argumentTextRef])
            
            self.dictionary = argumentText.split(separator: .newlineSequence)
                .map(String.init)
                .compactMap(Self.parseArgumentLineIntoPair)
                .reduce(into: [String: String]()) { output, pair in
                    output[pair.key] = pair.value
                }
        } else {
            self.dictionary = [:]
        }
    }

    fileprivate static func parseArgumentLineIntoPair(_ line: String) -> (key: String, value: String)? {
        let argComponents = line.split(separator: ":", maxSplits: 1)
        
        guard argComponents.count == 2 else { return nil }
        
        return (
            argComponents.first!.trimmingCharacters(in: .whitespaces),
            argComponents.last!.trimmingCharacters(in: .whitespaces)
        )
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
