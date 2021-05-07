import Foundation

struct TodoBlock: Hashable, Identifiable, TextBlockContent {
    let id: String
    var completed: Bool
    var content: String
    
    init(content: String = "", completed: Bool = false) {
        self.id = UUID().uuidString
        self.content = content
        self.completed = completed
    }
    
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
