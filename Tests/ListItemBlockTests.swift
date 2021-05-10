import XCTest
@testable import Taper

class ListItemBlockTests: XCTestCase {
    func testNextForNumberedListIncreasesItemNumber() {
        let item = ListItemBlock(text: "item", number: 123, style: .numbered)
        let next = item.next()
        
        XCTAssertEqual(next.number, 124)
    }
}
