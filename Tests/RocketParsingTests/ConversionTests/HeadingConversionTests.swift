import XCTest
@testable import RocketParsing

final class HeadingConversionTests: XCTestCase {
    func test_heading1Parsing() throws {
        let markdown = """
        # Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h1>Heading</h1></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading2Parsing() throws {
        let markdown = """
        ## Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h2>Heading</h2></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading3Parsing() throws {
        let markdown = """
        ### Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h3>Heading</h3></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading4Parsing() throws {
        let markdown = """
        #### Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h4>Heading</h4></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading5Parsing() throws {
        let markdown = """
        ##### Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h5>Heading</h5></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading6Parsing() throws {
        let markdown = """
        ###### Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h6>Heading</h6></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_heading7Parsing() throws {
        let markdown = """
        ######## Heading
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><p>######## Heading</p></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_multipleHeadingParsing() throws {
        let markdown = """
        # Heading
        
        ## Heading 2
        
        #### Heading 4
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><h1>Heading</h1><h2>Heading 2</h2><h4>Heading 4</h4></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
