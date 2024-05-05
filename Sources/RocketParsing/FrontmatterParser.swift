import RegexBuilder

let argumentTextRef = Reference(Substring.self)

let frontmatterRegex = Regex {
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

func parseFrontmatter(from markdown: String) -> [String: String] {
    guard let match = markdown.prefixMatch(of: frontmatterRegex) else { return [:] }
    
    let argumentText = String(match[argumentTextRef])
    
    return argumentText.split(separator: .newlineSequence)
        .map(String.init)
        .compactMap(parseArgumentLineIntoPair)
        .reduce(into: [String: String]()) { output, pair in
            output[pair.key] = pair.value
        }
}

fileprivate func parseArgumentLineIntoPair(_ line: String) -> (key: String, value: String)? {
    let argComponents = line.split(separator: ":", maxSplits: 1)
    
    guard argComponents.count == 2 else { return nil }
    
    return (
        argComponents.first!.trimmingCharacters(in: .whitespaces),
        argComponents.last!.trimmingCharacters(in: .whitespaces)
    )
}

func removeFrontmatter(from markdown: String) -> String {
    String(markdown.trimmingPrefix(frontmatterRegex))
}
