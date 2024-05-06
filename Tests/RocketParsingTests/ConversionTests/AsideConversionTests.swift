import XCTest
@testable import RocketParsing

import Markdown

final class AsideConversionTests: XCTestCase {
    func test_asideBasicSingleLine() throws {
        let markdown = """
        > note: This is a `note` aside.
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <aside data-kind="note">
        <p>This is a <code>note</code> aside.</p></aside>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_asideBasicMultiLine() throws {
        let markdown = """
        > tip: This is a `tip` aside.
        > It may have a presentation similar to a block quote, but with a
        > different meaning, as it doesn't quote speech.
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <aside data-kind="tip">
        <p>This is a <code>tip</code> aside.\nIt may have a presentation similar to a block quote, but with a\ndifferent meaning, as it doesn&apos;t quote speech.</p></aside>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_asideBlock() throws {
        let markdown = """
        > [!tip]
        > This is a `tip` aside.
        > It may have a presentation similar to a block quote, but with a
        > different meaning, as it doesn't quote speech.
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <aside data-class="tip">
        <p>This is a <code>tip</code> aside.\nIt may have a presentation similar to a block quote, but with a\ndifferent meaning, as it doesn&apos;t quote speech.</p></aside>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_asideParsingDoesNotInterfereWithBlockQuoteParsing() throws {
        let markdown = """
        > This is a block quote
        > It should be presented like a block quote
        """
        
        var converter = HTMLConverter(markdown: markdown)
        let html = try converter.generateHTML()
        let expectedHTML = """
        <blockquote>
        <p>This is a block quote\nIt should be presented like a block quote</p></blockquote>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
