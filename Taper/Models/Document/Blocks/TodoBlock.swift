import Foundation

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
