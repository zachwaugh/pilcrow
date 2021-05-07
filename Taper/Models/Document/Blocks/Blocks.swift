import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
    case listItem(ListItemBlock)
    
    func empty() -> Block {
        blockable.empty().asBlock()
    }
    
    func next() -> Block {
        blockable.next().asBlock()
    }
    
    var blockable: Blockable {
        switch self {
        case .text(let block):
            return block
        case .todo(let block):
            return block
        case .listItem(let block):
            return block
        }
    }
}

protocol Blockable {
    var isEmpty: Bool { get }

    func asBlock() -> Block
    func empty() -> Self
    func next() -> Self
}

extension Blockable {
    func next() -> Self {
        empty()
    }
}

protocol TextBlockable: Blockable {
    var content: String { get set }
}

extension TextBlockable {
    var isEmpty: Bool {
        content.isEmpty
    }
}
