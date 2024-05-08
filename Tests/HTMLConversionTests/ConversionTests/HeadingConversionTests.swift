import XCTest
@testable import HTMLConversion

final class HeadingConversionTests: XCTestCase {
    func test_heading1Parsing() throws {
        let markdown = """
        # Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h1>Heading</h1>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading2Parsing() throws {
        let markdown = """
        ## Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h2>Heading</h2>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading3Parsing() throws {
        let markdown = """
        ### Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h3>Heading</h3>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading4Parsing() throws {
        let markdown = """
        #### Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h4>Heading</h4>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading5Parsing() throws {
        let markdown = """
        ##### Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h5>Heading</h5>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading6Parsing() throws {
        let markdown = """
        ###### Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h6>Heading</h6>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading7Parsing() throws {
        let markdown = """
        ######## Heading
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <p>######## Heading</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multipleHeadingParsing() throws {
        let markdown = """
        # Heading
        
        ## Heading 2
        
        #### Heading 4
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <h1>Heading</h1><h2>Heading 2</h2><h4>Heading 4</h4>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
