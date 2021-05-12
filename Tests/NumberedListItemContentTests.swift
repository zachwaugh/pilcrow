import XCTest
@testable import Pilcrow

class NumberedListItemContentTests: XCTestCase {
    func testNextForNumberedListIncreasesItemNumber() {
        let item = NumberedListItemContent(text: "item", number: 123)
        let next = item.next()
        
        XCTAssertEqual(next.number, 124)
    }
}
