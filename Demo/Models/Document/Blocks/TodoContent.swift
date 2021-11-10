import Foundation

struct TodoContent: Hashable, Identifiable, TextBlockContent {
    let id: String
    var text: String
    var completed: Bool
    
    init() {
        self.init(text: "")
    }
    
    init(text: String) {
        self.init(text: text, completed: false)
    }
    
    init(text: String, completed: Bool) {
        self.id = UUID().uuidString
        self.text = text
        self.completed = completed
    }
    
    mutating func toggleCompletion() {
        completed.toggle()
    }
    
    func asBlock() -> Block {
        .todo(self)
    }
    
    func empty() -> TodoContent {
        TodoContent()
    }
}
