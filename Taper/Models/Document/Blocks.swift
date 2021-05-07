import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
}

struct TextBlock: Hashable {
    let identifier = UUID()
    var content: String = ""
    var style: TextStyle = .paragraph
    
    func asBlock() -> Block {
        .text(self)
    }
}

struct TodoBlock: Hashable {
    let identifier = UUID()
    var completed: Bool = false
    var content: String = ""
    
    mutating func toggle() {
        completed.toggle()
    }
    
    func asBlock() -> Block {
        .todo(self)
    }
}
