import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
    case listItem(ListItemBlock)
    
    func empty() -> Block {
        blockable.empty().asBlock()
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
    func asBlock() -> Block
    func empty() -> Self
}

protocol TextBlockable: Blockable {
    var content: String { get set }
}

struct TextBlock: Hashable, TextBlockable {
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

struct TodoBlock: Hashable, TextBlockable {
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


enum ListItemStyle: Hashable {
    case bullet, number(Int)
}

struct ListItemBlock: Hashable, TextBlockable {
    let identifier = UUID()
    var content: String = ""
    var style: ListItemStyle = .bullet
    
    func asBlock() -> Block {
        .listItem(self)
    }
    
    func empty() -> ListItemBlock {
        ListItemBlock(style: style)
    }
}
