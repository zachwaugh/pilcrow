import Foundation

public enum EditResult {
    case inserted(Block.ID)
    case updatedKind(Block.ID), updatedContent(Block.ID)
    case deleted(Block.ID)
    
    case moved
}
