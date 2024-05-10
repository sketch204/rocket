import XCTest
@testable import Rocket
import PathKit

final class ContextTests: XCTestCase {
    func test_defaultsForPathConfig() throws {
        let defaults = [
            Config.Defaults(path: "/path/to", values: ["key": "value"])
        ]
        let config = Config(defaults: defaults)
        
        let path = Path("/path/to/file")
        
        let context = Context.defaults(for: path, config: config)
        
        XCTAssertEqual(context.dictionary.count, 1)
        let value = try XCTUnwrap(context["key"] as? String)
        XCTAssertEqual(value, "value")
    }
}
