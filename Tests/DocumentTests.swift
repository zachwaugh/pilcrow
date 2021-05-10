import XCTest
@testable import Taper

class DocumentTests: XCTestCase {
    func testJSONEncodingAndDecoding() {
        let document = Document(title: "Test document", blocks: [
            .text(TextBlock(text: "Text Block")),
            .todo(TodoBlock(text: "Text Block", completed: true)),
            .listItem(ListItemBlock(text: "List Item Block", style: .bulleted)),
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
