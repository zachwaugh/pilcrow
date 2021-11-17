import XCTest
@testable import Pilcrow

class DocumentEditorTests: XCTestCase {
    private let paragraphBlock = Block(content: "paragraph", kind: .paragraph)
    private let dividerBlock = Block(kind: .divider)
    private let headingBlock = Block(content: "heading", kind: .heading)
    
    private var simpleDocument: Document {
        Document(blocks: [
            paragraphBlock,
            dividerBlock,
            headingBlock
        ])
    }
    
    // MARK: - Moves
    
    func testMoveBlockToBeginning() {
        let editor = Editor(document: simpleDocument)
        editor.moveBlock(paragraphBlock, to: 0)
        
        let expectedDocument = Document(blocks: [
            paragraphBlock,
            dividerBlock,
            headingBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
    
    func testMoveBlockToEnd() {
        let document = simpleDocument
        let editor = Editor(document: document)
        editor.moveBlock(paragraphBlock, to: document.blocks.count - 1)
        
        let expectedDocument = Document(blocks: [
            dividerBlock,
            headingBlock,
            paragraphBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
    
    func testMoveBlockPastEndInsertsAtEnd() {
        let document = simpleDocument
        let editor = Editor(document: document)
        editor.moveBlock(paragraphBlock, to: 100)
        
        let expectedDocument = Document(blocks: [
            dividerBlock,
            headingBlock,
            paragraphBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
}
