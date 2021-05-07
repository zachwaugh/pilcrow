import UIKit

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
    case listItem(ListItemBlock)
    
    var content: BlockContent {
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

protocol BlockContent: Codable {
    var isEmpty: Bool { get }

    func asBlock() -> Block
    func empty() -> Self
    func next() -> Self
}

extension BlockContent {
    func next() -> Self {
        empty()
    }
}

protocol TextBlockContent: BlockContent {
    var text: String { get set }
}

extension TextBlockContent {
    var isEmpty: Bool {
        text.isEmpty
    }
}
