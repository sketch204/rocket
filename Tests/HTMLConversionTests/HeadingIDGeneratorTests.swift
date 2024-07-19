import XCTest
@testable import HTMLConversion
import Markdown

final class HeadingIDGeneratorTests: XCTestCase {
    func test_generateHeadingIDs() {
        var generator = HeadingIDGenerator()
        
        let id = generator.generateHeadingId(from: "Some heading content 123")
        let expectedId = "some-heading-content-123"
        XCTAssertEqual(id, expectedId)
    }
    
    func test_removesInvalidCharacters() {
        var generator = HeadingIDGenerator()
        
        let id = generator.generateHeadingId(from: "🚀 LFG!!!!")
        let expectedId = "lfg"
        XCTAssertEqual(id, expectedId)
    }
    
    func test_deduplicatesIDs() throws {
        var generator = HeadingIDGenerator()
        
        let id1 = generator.generateHeadingId(from: "heading")
        let expectedId1 = "heading"
        XCTAssertEqual(id1, expectedId1)
        
        let id2 = generator.generateHeadingId(from: "heading")
        let expectedId2 = "heading-2"
        XCTAssertEqual(id2, expectedId2)
        
        let id3 = generator.generateHeadingId(from: "heading")
        let expectedId3 = "heading-3"
        XCTAssertEqual(id3, expectedId3)
    }
}
