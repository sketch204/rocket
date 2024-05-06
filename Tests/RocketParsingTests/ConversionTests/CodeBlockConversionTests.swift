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
        <pre><code>module SwiftLibraryName {
            header &quot;bridgingHeaderName&quot;
            link &quot;CLibraryName&quot;
            export *
        }
        </code></pre>
        
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
        <pre><code class="language-swift">let package = Package(
            name: &quot;Curses&quot;,
            products: [...],
            targets: [
                .target(name: &quot;Curses&quot;, dependencies: [&quot;Cncurses&quot;]),  // Add dependency here
                .systemLibrary(name: &quot;Cncurses&quot;, path: &quot;Sources/Cncurses&quot;),
            ]
        )
        </code></pre>
        
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
        <pre><code class="language-c">#include &lt;ncurses.h&gt;
        </code></pre>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
