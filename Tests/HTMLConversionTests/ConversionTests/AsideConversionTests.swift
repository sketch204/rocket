import XCTest
@testable import HTMLConversion

import Markdown

final class AsideConversionTests: XCTestCase {
    func test_asideBasicSingleLine() {
        let markdown = """
        > note: This is a `note` aside.
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <aside data-kind="note">
        <h1>Note</h1><p>This is a <code>note</code> aside.</p></aside>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
    func test_asideBasicMultiLine() {
        let markdown = """
        > tip: This is a `tip` aside.
        > It may have a presentation similar to a block quote, but with a
        > different meaning, as it doesn't quote speech.
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <aside data-kind="tip">
        <h1>Tip</h1><p>This is a <code>tip</code> aside.\nIt may have a presentation similar to a block quote, but with a\ndifferent meaning, as it doesn&apos;t quote speech.</p></aside>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
    
//    func test_asideBlock() {
//        let markdown = """
//        > [!tip]
//        > This is a `tip` aside.
//        > It may have a presentation similar to a block quote, but with a
//        > different meaning, as it doesn't quote speech.
//        """
//        
//        let html = HTMLConverter.convert(markdown: markdown)
//        let expectedHTML = """
//        <aside data-class="tip">
//        <p>This is a <code>tip</code> aside.\nIt may have a presentation similar to a block quote, but with a\ndifferent meaning, as it doesn&apos;t quote speech.</p></aside>
//        
//        """
//        XCTAssertEqual(html, expectedHTML)
//    }
    
    func test_asideParsingDoesNotInterfereWithBlockQuoteParsing() {
        let markdown = """
        > This is a block quote
        > It should be presented like a block quote
        """
        
        let html = HTMLConverter.convert(markdown: markdown)
        let expectedHTML = """
        <blockquote>
        <p>This is a block quote\nIt should be presented like a block quote</p></blockquote>
        
        """
        XCTAssertEqual(html, expectedHTML)
    }
}
