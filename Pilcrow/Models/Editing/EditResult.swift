import Foundation

public enum EditResult {
    case inserted(Block.ID), updatedKind(Block.ID), updatedContent(Block.ID), deleted(Block.ID)
    
    public var id: Block.ID {
        switch self {
        case .inserted(let id), .updatedKind(let id), .updatedContent(let id), .deleted(let id):
            return id
        }
    }
}
