import Foundation

enum EditResult {
    case inserted(Int), invalidated, updated, deleted(Int)
}

final class DocumentEditor {
    private(set) var document: Document
    
    init(document: Document) {
        self.document = document
    }
    
    // MARK: - Editing
    
    func apply(edit: TextEdit, to block: Block) -> EditResult? {
        switch edit {
        case .insertNewline:
            return insertBlock(block.content.next().asBlock(), after: block)
        case .deleteAtBeginning:
            return deleteBlock(block)
        case .update(let content):
            updateBlockTextContent(content, block: block)
            return .invalidated
        }
    }
    
    func moveBlock(_ block: Block, to row: Int) {
        guard let sourceRow = index(of: block) else { return }
        
        let destinationRow = min(row, document.blocks.count - 1)
        let block = document.blocks.remove(at: sourceRow)
        document.blocks.insert(block, at: destinationRow)
    }

    func toggleCompletion(for block: Block) -> EditResult? {
        guard var content = block.content as? TodoContent else { return nil }
        
        content.toggleCompletion()
        updateBlockContent(block, content: content)
        return .updated
    }
    
    // MARK: - Inserts
    
    func insertBlock(_ newBlock: Block, after existingBlock: Block) -> EditResult {
        guard let index = index(of: existingBlock) else {
            fatalError("Block not found in document! \(existingBlock)")
        }
        
        let newIndex = index + 1
        document.blocks.insert(newBlock, at: newIndex)
        return .inserted(newIndex)
    }
    
    @discardableResult
    func appendNewBlock() -> EditResult {
        if let block = document.blocks.last {
            return appendBlock(block.content.empty().asBlock())
        } else {
            return appendBlock(ParagraphContent().asBlock())
        }
    }
    
    @discardableResult
    func appendBlock(_ block: Block) -> EditResult {
        document.blocks.append(block)
        return .inserted(document.blocks.endIndex - 1)
    }
    
    @discardableResult
    func appendBlocks(_ blocks: [Block]) -> EditResult {
        document.blocks += blocks
        return .inserted(document.blocks.endIndex - 1)
    }
    
    // MARK: - Updates
    
    private func updateBlockTextContent(_ text: String, block: Block) {
        guard var content = block.content as? TextBlockContent else { return }

        content.text = text
        updateBlockContent(block, content: content)
    }
    
    private func updateBlockContent(_ block: Block, content: BlockContent) {
        guard let index = index(of: block) else { return }

        document.blocks[index] = content.asBlock()
    }
    
    // MARK: - Deletions
    
    @discardableResult
    func deleteBlock(_ block: Block) -> EditResult {
        guard let index = index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        return .deleted(index)
    }
    
    // MARK: - Blocks
    
    private func index(of block: Block) -> Int? {
        document.blocks.firstIndex(of: block)
    }
}
