import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
    
    func empty() -> Block {
        switch self {
        case .text(let block):
            return block.empty().asBlock()
        case .todo(let block):
            return block.empty().asBlock()
        }
    }
}

protocol Blockable {
    func asBlock() -> Block
    func empty() -> Self
}

struct TextBlock: Hashable, Blockable {
    let identifier = UUID()
    var content: String = ""
    var style: TextStyle = .paragraph
    
    func asBlock() -> Block {
        .text(self)
    }
    
    func empty() -> TextBlock {
        TextBlock(style: style)
    }
}

struct TodoBlock: Hashable, Blockable {
    let identifier = UUID()
    var completed: Bool = false
    var content: String = ""
    
    mutating func toggle() {
        completed.toggle()
    }
    
    func asBlock() -> Block {
        .todo(self)
    }
    
    func empty() -> TodoBlock {
        TodoBlock()
    }
}
