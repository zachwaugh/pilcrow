import Foundation

struct Document {
    var title: String = "Untitled"
    var blocks: [Block] = []
}

enum BlockKind {
    case text, todo
}

protocol Block {
    var kind: BlockKind { get }
}

struct TextBlock: Block {
    var kind: BlockKind { .text }
    let content: String
}

struct TodoBlock: Block {
    var kind: BlockKind { .todo }

    let completed: Bool
    let content: String
}
