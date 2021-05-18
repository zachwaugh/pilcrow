import XCTest
@testable import Pilcrow

class DocumentEditorTests: XCTestCase {
    private let paragraphBlock = ParagraphContent(text: "paragraph").asBlock()
    private let dividerBlock = DividerContent().asBlock()
    private let headingBlock = HeadingContent(text: "heading").asBlock()
    
    private var simpleDocument: Document {
        Document(
            name: "Test",
            blocks: [
                paragraphBlock,
                dividerBlock,
                headingBlock
            ]
        )
    }
    
    // MARK: - Moves
    
    func testMoveBlockToBeginning() {
        let editor = DocumentEditor(document: simpleDocument)
        editor.moveBlock(paragraphBlock, to: 0)
        
        let expectedDocument = Document(name: "Test", blocks: [
            paragraphBlock,
            dividerBlock,
            headingBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
    
    func testMoveBlockToEnd() {
        let document = simpleDocument
        let editor = DocumentEditor(document: document)
        editor.moveBlock(paragraphBlock, to: document.blocks.count - 1)
        
        let expectedDocument = Document(name: "Test", blocks: [
            dividerBlock,
            headingBlock,
            paragraphBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
    
    func testMoveBlockPastEndInsertsAtEnd() {
        let document = simpleDocument
        let editor = DocumentEditor(document: document)
        editor.moveBlock(paragraphBlock, to: 100)
        
        let expectedDocument = Document(name: "Test", blocks: [
            dividerBlock,
            headingBlock,
            paragraphBlock
        ])
        
        XCTAssertEqual(editor.document, expectedDocument)
    }
}
