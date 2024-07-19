import XCTest
@testable import Rocket
import HTMLConversion

final class TableOfContentsTagTests: XCTestCase {
    typealias TableOfContents = CustomTags.TableOfContents
    
    func test_generatesTableOfContents() {
        let toc = TOC(entries: [
            TOC.Entry(level: 1, id: "heading", contents: "Heading"),
            TOC.Entry(level: 2, id: "sub-section", contents: "Sub section"),
            TOC.Entry(level: 2, id: "sub-section-2", contents: "Sub section 2"),
            TOC.Entry(level: 3, id: "sub-sub-section", contents: ""),
            TOC.Entry(level: 1, id: "conclusion", contents: "Conclusion"),
        ])
        let config = Config()
        let context = Context(dictionary: [
            "page": [
                "tableOfContents": toc.contextRepresentation
            ]
        ])
        
        let content = TableOfContents.generateContent(with: config, context: context)
        let expectedContent = """
        <ul>
        <li><a href="#heading">Heading</a><ul>
        <li><a href="#sub-section">Sub section</a></li>
        <li><a href="#sub-section-2">Sub section 2</a><ul>
        <li><a href="#sub-sub-section"></a></li>
        </ul></li>
        </ul></li>
        <li><a href="#conclusion">Conclusion</a></li>
        </ul>
        """
        
        XCTAssertEqual(content, expectedContent)
    }
    
    func test_doesGenerateTableOfContents_whenEmpty() {
        let config = Config()
        let context = Context(dictionary: [
            "page": [
                "tableOfContents": TOC(entries: [])
            ]
        ])
        
        let content = TableOfContents.generateContent(with: config, context: context)
        let expectedContent = ""
        
        XCTAssertEqual(content, expectedContent)
    }
    
    func test_doesGenerateTableOfContents_whenUnavailable() {
        let config = Config()
        let context = Context()
        
        let content = TableOfContents.generateContent(with: config, context: context)
        let expectedContent = ""
        
        XCTAssertEqual(content, expectedContent)
    }
}
