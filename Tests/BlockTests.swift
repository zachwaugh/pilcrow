import XCTest
@testable import Pilcrow

class BlockTests: XCTestCase {
    func testInitAutomaticallyProvidesDefaults() {
        let block = Block()
        
        XCTAssertFalse(block.id.isEmpty)
        XCTAssertEqual(block.content, "")
        XCTAssertEqual(block.kind, .paragraph)
        XCTAssertTrue(block.properties.isEmpty)
    }
    
    func testBlockStoresProperties() {
        let block = Block(content: "test", properties: ["complete": "true"])
        XCTAssertEqual(block.properties["complete"], "true")
    }
    
    func testBlockPropertiesAccessibleViaSubscript() {
        let block = Block(content: "test", properties: ["title": "foo", "complete": "true"])
        
        XCTAssertEqual(block["title"], "foo")
        XCTAssertEqual(block["complete"], "true")
        XCTAssertNil(block["missing"])
    }
    
    func textNextReturnsANewBlockOfSameKind() {
        let block1 = Block()
        let block2 = block1.next()
        
        XCTAssertNotEqual(block1, block2)
        XCTAssertEqual(block1.kind, block2.kind)
    }
}
