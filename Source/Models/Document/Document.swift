import Foundation

struct Document: Codable, Equatable {
    static let fileExtension = "pilcrow"
    
    let id: String
    var name: String
    var blocks: [Block]
    
    init(name: String = "Untitled", blocks: [Block] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.blocks = blocks
    }
}

extension Document {
    /// Test document contains a sample of all blocks
    static var test: Document {
        let blocks: [BlockContent] = [
            TextBlock(text: "Heading", style: .heading),
            TextBlock(text: "Paragraph"),
            ListItemBlock(text: "Bullet list item", style: .bulleted),
            ListItemBlock(text: "Ordered list item", style: .numbered),
            
            TextBlock(text: "Paragraph that is much longer so it will wrap to multiple lines"),
            TodoBlock(text: "Todo"),
            TextBlock(text: "Another paragraph"),
            TodoBlock(text: "Completed todo that is also much longer so we can test how it wraps", completed: true),
            TextBlock(text: "Final paragraph"),
        ]
        
        return Document(
            name: "¶ Test Document",
            blocks: blocks.map { $0.asBlock() }
        )
    }
}
