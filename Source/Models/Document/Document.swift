import Foundation

struct Document: Codable, Equatable {
    var blocks: [Block] = []
    
    var isEmpty: Bool {
        blocks.isEmpty
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
            blocks: blocks.map { $0.asBlock() }
        )
    }
}
