import XCTest
@testable import RocketParsing

final class ParagraphConversionTests: XCTestCase {
    func test_singleLineParagraph() {
        let markdown = """
        This is a paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = converter.generateHTML()
        let expectedHTML = """
        <body><p>This is a paragraph</p></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multiLineParagraph() {
        let markdown = """
        This is a paragraph
        This is still the same paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = converter.generateHTML()
        let expectedHTML = """
        <body><p>This is a paragraph<br/>This is still the same paragraph</p></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multipleParagraphs() {
        let markdown = """
        This is a paragraph
        This is still the same paragraph
        
        This is a different paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = converter.generateHTML()
        let expectedHTML = """
        <body><p>This is a paragraph<br/>This is still the same paragraph</p><p>This is a different paragraph</p></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
