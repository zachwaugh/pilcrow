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
            HeadingContent(text: "Heading"),
            ParagraphContent(text: "Paragraph"),
            BulletedListItemContent(text: "Bullet list item"),
            NumberedListItemContent(text: "Ordered list item"),
            DividerContent(),
            ParagraphContent(text: "Paragraph that is much longer so it will wrap to multiple lines"),
            TodoContent(text: "Todo"),
            ParagraphContent(text: "Another paragraph"),
            TodoContent(text: "Completed todo that is also much longer so we can test how it wraps", completed: true),
            ParagraphContent(text: "Final paragraph"),
            QuoteContent(text: "You miss 100% of the shots you don't take - Wayne Gretzky\n— Michael Scott")
        ]
        
        return Document(
            name: "¶ Test Document",
            blocks: blocks.map { $0.asBlock() }
        )
    }
}
