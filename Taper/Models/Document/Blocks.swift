import Foundation

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
}

struct TextBlock: Hashable {
    let identifier = UUID()
    let content: String
}

struct TodoBlock: Hashable {
    let identifier = UUID()
    let completed: Bool
    let content: String
}
