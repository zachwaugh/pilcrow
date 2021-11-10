import XCTest
@testable import Demo

class NumberedListItemContentTests: XCTestCase {
    func testNextForNumberedListIncreasesItemNumber() {
        let item = NumberedListItemContent(text: "item", number: 123)
        
        guard let next = item.next() as? NumberedListItemContent else {
            XCTFail("Wrong content type returned")
            return
        }
        
        XCTAssertEqual(next.number, 124)
    }
}
