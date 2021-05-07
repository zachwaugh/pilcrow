import Foundation

enum EditResult {
    case inserted, invalidated, updated, deleted
}

final class DocumentEditor {
    private(set) var document: Document
    
    init(document: Document) {
        self.document = document
    }
    
    // MARK: - Creation
    
    // MARK: - Editing
    
    func apply(edit: TextEdit, to block: Block) -> EditResult? {
        switch edit {
        case .insertNewline:
            insertBlock(block.content.next().asBlock(), after: block)
            return .inserted
        case .deleteAtBeginning:
            deleteBlock(block)
            return .deleted
        case .update(let content):
            updateBlockTextContent(content, block: block)
            return .invalidated
        }
    }
    
    func toggleCompletion(for block: Block) -> EditResult? {
        guard var content = block.content as? TodoBlock else { return nil }
        
        content.toggleCompletion()
        updateBlockContent(block, content: content)
        return .updated
    }
    
    // MARK: - Inserts
    
    private func insertBlock(_ newBlock: Block, after existingBlock: Block) {
        if let index = index(of: existingBlock), index < document.blocks.endIndex {
            document.blocks.insert(newBlock, at: index + 1)
            //updateDataSource()
            //focusBlock(newBlock)
        } else {
            appendNewBlock(newBlock)
        }
    }
    
    private func insertNewBlock(for kind: BlockKind) {
        let block = makeBlock(for: kind)
        insertNewBlock(block)
    }
    
    private func makeBlock(for kind: BlockKind) -> Block {
        switch kind {
        case .heading:
            return TextBlock(style: .heading).asBlock()
        case .paragraph:
            return TextBlock(style: .paragraph).asBlock()
        case .todo:
            return TodoBlock().asBlock()
        case .bulletedListItem:
            return ListItemBlock(style: .bulleted).asBlock()
        case .numberedListItem:
            return ListItemBlock(style: .numbered).asBlock()
        }
    }
    
    /// Inserts will happen by default after active row, or at the end
    private func insertNewBlock(_ block: Block) {
        // TODO: find current active block
        appendNewBlock(block)
    }
    
    /// Appends a block at the end, ensuring it's the correct type based on the
    private func autoAppendNewBlock() {
        guard let block = document.blocks.last else {
            appendNewBlock(TextBlock().asBlock())
            return
        }
        
        if !block.content.isEmpty {
            appendNewBlock(block.content.empty().asBlock())
        } else {
            //focusBlock(block)
        }
    }
    
    private func appendNewBlock(_ block: Block) {
        document.blocks.append(block)
        //updateDataSource(animated: true)
        //focusBlock(block)
    }
    
    // MARK: - Updates
    
    private func updateBlockTextContent(_ text: String, block: Block) {
        guard var content = block.content as? TextBlockContent else { return }

        content.text = text
        updateBlockContent(block, content: content, refresh: false)
    }
    
    private func updateBlockContent(_ block: Block, content: BlockContent, refresh: Bool = true) {
        guard let index = index(of: block) else { return }

        document.blocks[index] = content.asBlock()
    }
    
    // MARK: - Deletions
    
    private func deleteBlock(_ block: Block) {
        guard let index = index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        //updateDataSource()
        
        let previousIndex = index - 1
        if previousIndex >= 0, !document.blocks.isEmpty {
            //focusBlock(document.blocks[previousIndex])
        }
    }
    
    // MARK: - Blocks
    
    private func index(of block: Block) -> Int? {
        document.blocks.firstIndex(of: block)
    }
}
