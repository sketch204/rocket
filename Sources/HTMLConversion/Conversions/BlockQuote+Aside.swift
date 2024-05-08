import Markdown

extension BlockQuote {
     /// Conservatively checks the text of this block quote to see whether it can be parsed as an aside.
     ///
     /// Whereas ``Aside/init(_:)`` will use all the text before the first colon in the first line,
     /// or else return an ``Aside`` with a ``Aside/Kind-swift.struct`` of ``Aside/Kind/note``,
     /// this function will allow parsers to only parse an aside if there is a single-word aside
     /// marker in the first line, and otherwise fall back to a plain ``BlockQuote``.
     func isAside() -> Bool {
         guard let initialText = self.child(through: [
             (0, Paragraph.self),
             (0, Text.self),
         ]) as? Text,
               let firstColonIndex = initialText.string.firstIndex(where: { $0 == ":" }) else {
             return false
         }

         if let firstSpaceIndex = initialText.string.firstIndex(where: { $0 == " " }) {
             return firstSpaceIndex > firstColonIndex
         } else {
             return true
         }
     }
 }
