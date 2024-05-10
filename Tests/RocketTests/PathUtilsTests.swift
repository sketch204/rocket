import XCTest
@testable import Rocket
import PathKit

final class PathUtilsTests: XCTestCase {
    func test_relativeTo_withLeadingSlash() throws {
        let path = Path("/path/to/file")
        let parentPath = Path("/path/to")
        
        let relativePath = path.relative(to: parentPath, includeLeadingSlash: true)
        let expectedPath = Path("/file")
        
        XCTAssertEqual(relativePath, expectedPath)
    }
    
    func test_relativeTo_withoutLeadingSlash() throws {
        let path = Path("/path/to/file")
        let parentPath = Path("/path/to")
        
        let relativePath = path.relative(to: parentPath, includeLeadingSlash: false)
        let expectedPath = Path("file")
        
        XCTAssertEqual(relativePath, expectedPath)
    }
}
