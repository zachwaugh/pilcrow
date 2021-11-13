import Foundation
import Combine

/// Editor manages all edits to the document
/// ensuring a consistent state and notifying subscribers about changes
public final class Editor {
    public var changes = PassthroughSubject<EditResult, Never>()
    public private(set) var document: Document

    public init(document: Document) {
        self.document = document
    }
    
    // MARK: - Editing
    
    public func apply(edit: TextEdit, to block: Block) {
        let isEmpty = block.content.isEmpty
        let isParagraph = block.kind == .paragraph
        let isEmptyNonParagraph = isEmpty && !isParagraph
        
        switch edit {
        case .insertNewline where isEmptyNonParagraph,
             .deleteAtBeginning where isEmptyNonParagraph:
            // newline or delete for empty non-paragraph removes formatting and turns back into paragraph
            updateBlockKind(for: block, to: .paragraph)
        case .insertNewline:
            let newBlock = block.next()
            print("[Editor] inserting new block: \(newBlock)")
            insertBlock(newBlock, after: block)
        case .deleteAtBeginning:
            deleteBlock(block)
        case .update(let content):
            updateBlockContent(content, block: block)
        }
    }
    
    // MARK: - Todo

    public func toggleCompletion(for block: Block) {
        guard block.kind == .todo else { return }
        
        var updated = block
        updated.toggleCompletion()
        updateBlock(block, with: updated)
    }
    
    // MARK: - Inserts
    
    public func insertBlock(_ newBlock: Block, after existingBlock: Block) {
        guard let index = document.index(of: existingBlock) else {
            fatalError("Block not found in document! \(existingBlock)")
        }
        
        let newIndex = index + 1
        document.blocks.insert(newBlock, at: newIndex)
        changes.send(.inserted(newBlock.id))
    }
    
    public func appendNewBlock() {
        if let block = document.blocks.last {
            appendBlock(block.next())
        } else {
            appendBlock(Block(kind: .heading))
        }
    }
    
    public func appendBlock(_ block: Block) {
        document.blocks.append(block)
        changes.send(.inserted(block.id))
    }
    
    public func appendBlocks(_ blocks: [Block]) {
        document.blocks.append(contentsOf: blocks)
    }
    
    // MARK: - Moves
    
    public func moveBlock(_ block: Block, to row: Int) {
        guard let sourceRow = document.index(of: block) else { return }
        
        let destinationRow = min(row, document.blocks.count - 1)
        let block = document.blocks.remove(at: sourceRow)
        document.blocks.insert(block, at: destinationRow)
        changes.send(.moved)
    }
    
    // MARK: - Updates
    
    public func updateBlockKind(for block: Block, to kind: Block.Kind) {
        guard let index = document.index(of: block) else { return }
        
        var updated = block
        updated.kind = kind
        document.blocks[index] = updated
        changes.send(.updatedKind(block.id))
    }
    
    private func updateBlockContent(_ text: String, block: Block) {
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
    
    public func deleteBlock(_ block: Block) {
        guard let index = document.index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        changes.send(.deleted(block.id, index: index))
    }
}
