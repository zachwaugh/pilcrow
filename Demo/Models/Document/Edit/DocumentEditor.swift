import Foundation
import Combine
import Pilcrow

enum EditResult {
    case inserted(Block.ID), invalidated(Block.ID), updated(Block.ID), deleted(Block.ID)
    
    var id: Block.ID {
        switch self {
        case .inserted(let id), .invalidated(let id), .updated(let id), .deleted(let id):
            return id
        }
    }
}

/// Editor manages all edits to the document
/// ensuring a consistent state
final class DocumentEditor {
    private(set) var document: Document {
        didSet {
            edits += 1
        }
    }
    
    @Published var edits: Int = 0
    
    init(document: Document) {
        self.document = document
    }
    
    // MARK: - Editing
    
    func apply(edit: TextEdit, to block: Block) -> EditResult? {
        let isEmpty = block.content.isEmpty
        let isParagraph = block.kind == .paragraph
        let isEmptyNonParagraph = isEmpty && !isParagraph
        
        switch edit {
        case .insertNewline where isEmptyNonParagraph,
             .deleteAtBeginning where isEmptyNonParagraph:
            // newline or delete for empty non-paragraph removes formatting and turns back into paragraph
            return updateBlockKind(for: block, to: .paragraph)
        case .insertNewline:
            return insertBlock(block.next(), after: block)
        case .deleteAtBeginning:
            return deleteBlock(block)
        case .update(let content):
            let result = updateBlockTextContent(content, block: block)
            return result.map { .invalidated($0.id) }
        }
    }
    
    func moveBlock(_ block: Block, to row: Int) {
        guard let sourceRow = index(of: block) else { return }
        
        let destinationRow = min(row, document.blocks.count - 1)
        let block = document.blocks.remove(at: sourceRow)
        document.blocks.insert(block, at: destinationRow)
    }

    func toggleCompletion(for block: Block) -> EditResult? {
        guard block.kind == .todo else { return nil }
        
        var updated = block
        updated.properties["completed"] = block["completed"] == "true" ? "false" : "true"
        //content.toggleCompletion()
        return updateBlock(block, with: updated)
    }
    
    // MARK: - Inserts
    
    func insertBlock(_ newBlock: Block, after existingBlock: Block) -> EditResult {
        guard let index = index(of: existingBlock) else {
            fatalError("Block not found in document! \(existingBlock)")
        }
        
        let newIndex = index + 1
        document.blocks.insert(newBlock, at: newIndex)
        return .inserted(newBlock.id)
    }
    
    @discardableResult
    func appendNewBlock() -> EditResult {
        if let block = document.blocks.last {
            return appendBlock(block.next())
        } else {
            return appendBlock(Block(kind: .heading))
        }
    }
    
    @discardableResult
    func appendBlock(_ block: Block) -> EditResult {
        document.blocks.append(block)
        return .inserted(block.id)
    }
    
//    @discardableResult
//    func appendBlocks(_ blocks: [Block]) -> EditResult {
//        document.blocks += blocks
//        return .inserted(document.blocks.endIndex - 1)
//    }
    
    // MARK: - Updates
    
    func updateBlockKind(for block: Block, to kind: Block.Kind) -> EditResult? {
        guard let index = index(of: block) else { return nil }
        
        var updated = block
        updated.kind = kind
        document.blocks[index] = updated
        
        return .updated(block.id)
    }
    
    @discardableResult
    private func updateBlockTextContent(_ text: String, block: Block) -> EditResult? {
        var updated = block
        updated.content = text
        return updateBlock(block, with: updated)
    }
    
    @discardableResult
    private func updateBlock(_ block: Block, with updatedBlock: Block) -> EditResult? {
        guard let index = index(of: block) else { return nil }

        document.blocks[index] = updatedBlock
        return .updated(block.id)
    }
    
    // MARK: - Deletions
    
    @discardableResult
    func deleteBlock(_ block: Block) -> EditResult {
        guard let index = index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        return .deleted(block.id)
    }
    
    // MARK: - Blocks
    
    private func index(of block: Block) -> Int? {
        document.blocks.firstIndex(of: block)
    }
}
