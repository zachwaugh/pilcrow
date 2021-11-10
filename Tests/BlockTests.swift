import XCTest
@testable import Pilcrow

class BlockTests: XCTestCase {
    func testInitAutomaticallyCreatesIdAndAssignsPargraph() {
        let block = Block(content: "test")
        
        XCTAssertFalse(block.id.isEmpty)
        XCTAssertEqual(block.kind, .paragraph)
    }
}
