import Foundation
import Pilcrow

struct Document: Codable, Equatable {
    var blocks: [Block] = []
    
    var isEmpty: Bool {
        blocks.isEmpty
    }
}

extension Document {
    /// Test document contains a sample of all blocks
    static var test: Document {
        let blocks: [Block] = [
            Block(content: "Heading", kind: .heading),
            Block(content: "Paragraph", kind: .paragraph),
            Block(content: "Bullet list item", kind: .listItem, properties: ["type": "bullet"]),
            Block(content: "Ordered list item", kind: .listItem, properties: ["type": "numbered", "index": "1"]),
            Block(kind: .divider),
            Block(content: "Paragraph that is much longer so it will wrap to multiple lines"),
            Block(content: "Todo", kind: .todo),
            Block(content: "Another paragraph"),
            Block(content: "Completed todo that is also much longer so we can test how it wraps", kind: .listItem, properties: ["completed": "true"]),
            Block(content: "Final paragraph"),
            Block(content: "You miss 100% of the shots you don't take - Wayne Gretzky\n— Michael Scott", kind: .quote)
        ]
        
        return Document(
            blocks: blocks
        )
    }
}
