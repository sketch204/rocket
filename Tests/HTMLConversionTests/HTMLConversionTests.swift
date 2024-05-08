import XCTest
@testable import HTMLConversion
import Markdown

final class HTMLConversionTests: XCTestCase {
    func test_reservedHTMLCharactersReplaced() throws {
        let markdown = """
        This "text" doesn't not use reserved `<HTML>` characters &
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <p>This &quot;text&quot; doesn&apos;t not use reserved <code>&lt;HTML&gt;</code> characters &amp;</p>
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
