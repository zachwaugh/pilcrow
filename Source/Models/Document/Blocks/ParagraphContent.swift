import Foundation

struct ParagraphContent: Hashable, Identifiable, Codable, TextBlockContent {
    let id: String
    var text: String
    
    init(text: String = "") {
        self.id = UUID().uuidString
        self.text = text
    }
        
    func asBlock() -> Block {
        .paragraph(self)
    }
    
    func empty() -> ParagraphContent {
        ParagraphContent()
    }
}
