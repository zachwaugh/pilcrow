import Foundation

struct QuoteBlock: Hashable, Identifiable, Codable, TextBlockContent {
    let id: String
    var text: String
    
    init(text: String = "") {
        self.id = UUID().uuidString
        self.text = text
    }
        
    func asBlock() -> Block {
        .quote(self)
    }
    
    func empty() -> QuoteBlock {
        QuoteBlock()
    }
}
