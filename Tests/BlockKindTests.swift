import XCTest
@testable import Pilcrow

class BlockKindTests: XCTestCase {
    func testDefaultKinds() {
        XCTAssertEqual(Block.Kind.paragraph.rawValue, "paragraph")
    }
    
    func testCustomKind() {
        let myKind = Block.Kind("custom-kind")
        XCTAssertEqual(myKind.rawValue, "custom-kind")
    }
}
