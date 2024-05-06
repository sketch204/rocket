import XCTest
@testable import RocketParsing

import Markdown

final class CodeBlockConversionTests: XCTestCase {
    func test_parseIndentedMultilineCode() throws {
        let markdown = """
        ```
        module SwiftLibraryName {
            header "bridgingHeaderName"
            link "CLibraryName"
            export *
        }
        ```
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><pre><code>
        module SwiftLibraryName {
            header "bridgingHeaderName"
            link "CLibraryName"
            export *
        }
        </code></pre></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_parseLanguageSpecificCodeBlock() throws {
        let markdown = """
        ```Swift
        let package = Package(
            name: "Curses",
            products: [...],
            targets: [
                .target(name: "Curses", dependencies: ["Cncurses"]),  // Add dependency here
                .systemLibrary(name: "Cncurses", path: "Sources/Cncurses"),
            ]
        )
        ```
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><pre><code class="lang-swift">
        let package = Package(
            name: "Curses",
            products: [...],
            targets: [
                .target(name: "Curses", dependencies: ["Cncurses"]),  // Add dependency here
                .systemLibrary(name: "Cncurses", path: "Sources/Cncurses"),
            ]
        )
        </code></pre></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_parseCodeWithAngleBrackets() throws {
        let markdown = """
        ```C
        #include <ncurses.h>
        ```
        """
        
        print(Document(parsing: markdown, options: []).debugDescription())
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <body><pre><code class="lang-c">
        #include &lt;ncurses.h&gt;
        </code></pre></body>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
