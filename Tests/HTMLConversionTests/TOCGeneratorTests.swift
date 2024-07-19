import XCTest
@testable import HTMLConversion
import Markdown

final class TOCGeneratorTests: XCTestCase {
    func test_tocGeneration() {
        let markdown = """
        Preface
        
        # Heading
        Some content
        
        ## Sub section
        some more content
        
        ## Sub section 2
        Some more content still
        
        # Conclusion
        A conclusion
        """
        
        let toc = TOCGenerator.generate(from: markdown)
        let expectedTOC = TOC(entries: [
            TOC.Entry(level: 1, id: "heading", contents: "Heading"),
            TOC.Entry(level: 2, id: "sub-section", contents: "Sub section"),
            TOC.Entry(level: 2, id: "sub-section-2", contents: "Sub section 2"),
            TOC.Entry(level: 1, id: "conclusion", contents: "Conclusion"),
        ])
        XCTAssertEqual(toc, expectedTOC)
    }
    
    func test_tocGeneration_whenNoHeading() {
        let markdown = """
        Only text goes here.
        No headings.
        None at all...
        """
        
        let toc = TOCGenerator.generate(from: markdown)
        let expectedTOC = TOC(entries: [])
        XCTAssertEqual(toc, expectedTOC)
    }
    
    func test_tocGeneration_whenNoContent() {
        let markdown = ""
        
        let toc = TOCGenerator.generate(from: markdown)
        let expectedTOC = TOC(entries: [])
        XCTAssertEqual(toc, expectedTOC)
    }
}
