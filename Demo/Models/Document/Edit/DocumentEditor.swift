import Foundation
import Combine
import Pilcrow

enum EditResult {
    case inserted(Block.ID), updatedKind(Block.ID), updatedContent(Block.ID), deleted(Block.ID)
    
    var id: Block.ID {
        switch self {
        case .inserted(let id), .updatedKind(let id), .updatedContent(let id), .deleted(let id):
            return id
        }
    }
}

/// Editor manages all edits to the document
/// ensuring a consistent state
final class DocumentEditor {
    var changes = PassthroughSubject<EditResult, Never>()
    private(set) var document: Document

    init(document: Document) {
        self.document = document
    }
    
    // MARK: - Editing
    
    func apply(edit: TextEdit, to block: Block) {
        let isEmpty = block.content.isEmpty
        let isParagraph = block.kind == .paragraph
        let isEmptyNonParagraph = isEmpty && !isParagraph
        
        switch edit {
        case .insertNewline where isEmptyNonParagraph,
             .deleteAtBeginning where isEmptyNonParagraph:
            // newline or delete for empty non-paragraph removes formatting and turns back into paragraph
            updateBlockKind(for: block, to: .paragraph)
        case .insertNewline:
            insertBlock(block.next(), after: block)
        case .deleteAtBeginning:
            deleteBlock(block)
        case .update(let content):
            updateBlockTextContent(content, block: block)
        }
    }
    
    func moveBlock(_ block: Block, to row: Int) {
        guard let sourceRow = document.index(of: block) else { return }
        
        let destinationRow = min(row, document.blocks.count - 1)
        let block = document.blocks.remove(at: sourceRow)
        document.blocks.insert(block, at: destinationRow)
    }

    func toggleCompletion(for block: Block) {
        guard block.kind == .todo else { return }
        
        var updated = block
        updated.toggleCompletion()
        updateBlock(block, with: updated)
    }
    
    // MARK: - Inserts
    
    func insertBlock(_ newBlock: Block, after existingBlock: Block) {
        guard let index = document.index(of: existingBlock) else {
            fatalError("Block not found in document! \(existingBlock)")
        }
        
        let newIndex = index + 1
        document.blocks.insert(newBlock, at: newIndex)
        changes.send(.inserted(newBlock.id))
    }
    
    func appendNewBlock() {
        if let block = document.blocks.last {
            appendBlock(block.next())
        } else {
            appendBlock(Block(kind: .heading))
        }
    }
    
    func appendBlock(_ block: Block) {
        document.blocks.append(block)
        changes.send(.inserted(block.id))
    }
    
    func appendBlocks(_ blocks: [Block]) {
        document.blocks.append(contentsOf: blocks)
    }
    
    // MARK: - Updates
    
    func updateBlockKind(for block: Block, to kind: Block.Kind) {
        guard let index = document.index(of: block) else { return }
        
        var updated = block
        updated.kind = kind
        document.blocks[index] = updated
        changes.send(.updatedKind(block.id))
    }
    
    private func updateBlockTextContent(_ text: String, block: Block) {
        var updated = block
        updated.content = text
        updateBlock(block, with: updated)
    }
    
    private func updateBlock(_ block: Block, with updatedBlock: Block) {
        guard let index = document.index(of: block) else { return }

        document.blocks[index] = updatedBlock
        changes.send(.updatedContent(block.id))
    }
    
    // MARK: - Deletions
    
    func deleteBlock(_ block: Block) {
        guard let index = document.index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        changes.send(.deleted(block.id))
    }
}
