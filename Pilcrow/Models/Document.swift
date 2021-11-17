import Foundation

/// A document represents an array of blocks
/// Documents are Codable so they can be persisted/serialized
public struct Document: Codable, Equatable {
    public var blocks: [Block]
    
    public init(blocks: [Block] = []) {
        self.blocks = blocks
    }
    
    /// The document is empty when there are no blocks
    public var isEmpty: Bool {
        blocks.isEmpty
    }
    
    /// The index of a particular block, if present
    public func index(of block: Block) -> Int? {
        blocks.firstIndex { $0.id == block.id }
    }
    
    /// The block matching the passed-in `id`
    public func block(with id: Block.ID) -> Block? {
        blocks.first { $0.id == id }
    }
    
    /// The block at the specified index or nil
    public func block(at index: Int) -> Block? {
        guard index >= 0, index < blocks.count else { return nil }
        return blocks[index]
    }
}
