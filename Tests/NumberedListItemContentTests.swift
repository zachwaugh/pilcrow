import XCTest
@testable import Pilcrow

class NumberedListItemContentTests: XCTestCase {
    func skip_testNextForNumberedListIncreasesItemNumber() {
        let item = Block(content: "item", kind: .listItem, properties: ["number": "123"])
        let next = item.next()
        XCTAssertEqual(next["number"], "124")
    }
}
