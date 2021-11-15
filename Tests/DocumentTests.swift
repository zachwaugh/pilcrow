import XCTest
@testable import Pilcrow

class DocumentTests: XCTestCase {
    func testJSONEncodingAndDecoding() {
        let document = Document(blocks: [
            Block(content: "Text Block", kind: .paragraph),
            Block(content: "Todo Block", kind: .todo, properties: ["completed": "true"]),
            Block(content: "List Item Block", kind: .listItem)
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
