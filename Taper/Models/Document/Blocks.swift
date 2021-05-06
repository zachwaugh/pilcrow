import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
}

struct TextBlock: Hashable {
    let identifier = UUID()
    var content: String
}

struct TodoBlock: Hashable {
    let identifier = UUID()
    var completed: Bool
    var content: String
    
    mutating func toggle() {
        completed.toggle()
    }
}
