import XCTest
@testable import Pilcrow

class DocumentTests: XCTestCase {
    func testJSONEncodingAndDecoding() {
        let document = Document(blocks: [
            .paragraph(ParagraphContent(text: "Text Block")),
            .todo(TodoContent(text: "Text Block", completed: true)),
            .bulletedListItem(BulletedListItemContent(text: "List Item Block")),
        ])
        
        do {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let data = try encoder.encode(document)
            let decodedDocument = try decoder.decode(Document.self, from: data)
            XCTAssertEqual(document, decodedDocument)
        } catch {
            XCTFail("Error encoding document: \(error)")
        }
    }
}
