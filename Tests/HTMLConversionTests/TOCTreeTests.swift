import XCTest
@testable import HTMLConversion
import Markdown

final class TOCTreeTests: XCTestCase {
    func test_tocTreeGeneration() {
        let toc = TOC(entries: [
            TOC.Entry(level: 1, id: "heading", contents: "Heading"),
            TOC.Entry(level: 2, id: "sub-section", contents: "Sub section"),
            TOC.Entry(level: 2, id: "sub-section-2", contents: "Sub section 2"),
            TOC.Entry(level: 3, id: "sub-sub-section", contents: ""),
            TOC.Entry(level: 1, id: "conclusion", contents: "Conclusion"),
        ])
        
        let tree = TOC.Tree.createTrees(from: toc)
        let expectedTree = [
            TOC.Tree(id: "heading", contents: "Heading", children: [
                TOC.Tree(id: "sub-section", contents: "Sub section"),
                TOC.Tree(id: "sub-section-2", contents: "Sub section 2", children: [
                    TOC.Tree(id: "sub-sub-section", contents: "Sub sub section"),
                ]),
            ]),
            TOC.Tree(id: "conclusion", contents: "Conclusion"),
        ]
        XCTAssertEqual(tree, expectedTree)
    }
    
    func test_tocTreeGeneration_whenTocEmpty() {
        let toc = TOC(entries: [])
        
        let tree = TOC.Tree.createTrees(from: toc)
        let expectedTree = [TOC.Tree]()
        XCTAssertEqual(tree, expectedTree)
    }
}
