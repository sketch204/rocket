import XCTest
@testable import RocketParsing

final class ParagraphConversionTests: XCTestCase {
    func test_singleLineParagraph() throws {
        let markdown = """
        This is a paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <p>This is a paragraph</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multiLineParagraph() throws {
        let markdown = """
        This is a paragraph
        This is still the same paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <p>This is a paragraph\nThis is still the same paragraph</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multipleParagraphs() throws {
        let markdown = """
        This is a paragraph
        This is still the same paragraph
        
        This is a different paragraph
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <p>This is a paragraph\nThis is still the same paragraph</p><p>This is a different paragraph</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
