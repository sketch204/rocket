import XCTest
@testable import RocketParsing

final class FrontmatterParserTests: XCTestCase {
    let sampleMarkdownWithFrontmatter = """
    ---
    title: From C to Swift - Part 1
    description: Learn to how to integrate C system libraries into your Swift code
    tags: swift swiftpm c
    ---
    
    # Creating Tables
    
    Like a `List` you can create a table by passing in an array of `Identifiable` items to a `Table` struct which is followed by a builder. Unlike a `List`, you do not create views in the builder. Instead you define **columns**. Tables must be defined in terms of columns.
    """
    
    let sampleMarkdownEmptyFrontmatter = """
    ---
    ---
    
    # Creating Tables
    
    Like a `List` you can create a table by passing in an array of `Identifiable` items to a `Table` struct which is followed by a builder. Unlike a `List`, you do not create views in the builder. Instead you define **columns**. Tables must be defined in terms of columns.
    """
    
    let sampleMarkdownNoFrontmatter = """
    # Creating Tables
    
    Like a `List` you can create a table by passing in an array of `Identifiable` items to a `Table` struct which is followed by a builder. Unlike a `List`, you do not create views in the builder. Instead you define **columns**. Tables must be defined in terms of columns.
    """
    
    func test_parseFrontmatter_withFrontmatter() throws {
        let frontmatter = parseFrontmatter(from: sampleMarkdownWithFrontmatter)
        
        let expectedFrontmatter = [
            "title": "From C to Swift - Part 1",
            "description": "Learn to how to integrate C system libraries into your Swift code",
            "tags": "swift swiftpm c",
        ]
        
        XCTAssertEqual(frontmatter, expectedFrontmatter)
    }
    
    func test_parseFrontmatter_withEmptyFrontmatter() throws {
        let frontmatter = parseFrontmatter(from: sampleMarkdownEmptyFrontmatter)
        
        XCTAssertEqual(frontmatter, [:])
    }
    
    func test_parseFrontmatter_withNoFrontmatter() throws {
        let frontmatter = parseFrontmatter(from: sampleMarkdownNoFrontmatter)
        
        XCTAssertEqual(frontmatter, [:])
    }
}

