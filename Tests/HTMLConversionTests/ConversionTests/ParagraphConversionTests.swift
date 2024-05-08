import XCTest
@testable import HTMLConversion

final class ParagraphConversionTests: XCTestCase {
    func test_singleLineParagraph() throws {
        let markdown = """
        This is a paragraph
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
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
        
        let html = HTMLConverter.convert(markdown: markdown)
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
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <p>This is a paragraph\nThis is still the same paragraph</p><p>This is a different paragraph</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
