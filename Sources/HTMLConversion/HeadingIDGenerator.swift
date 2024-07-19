import Foundation
import Markdown

struct HeadingIDGenerator {
    private(set) var headingIDs = Set<String>()
    
    mutating func generateHeadingId(from contents: String) -> String {
        var id = contents
            .filter { $0.isASCII && ($0.isWholeNumber || $0.isLetter || $0.isWhitespace) }
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        
        var count = 0
        while headingIDs.contains(id) && count < 10 {
            id = incrementId(id)
            count += 1
        }
        headingIDs.insert(id)
        return id
    }
    
    private func incrementId(_ id: String) -> String {
        guard let lastCharacter = id.last else { return "" }
        
        if lastCharacter.isWholeNumber, let topId = Int(String(lastCharacter)) {
            return "\(id.dropLast())\(topId + 1)"
        } else {
            return "\(id)-2"
        }
    }
}
