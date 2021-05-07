import Foundation

struct TextBlock: Hashable, Identifiable, Codable, TextBlockContent {
    let id: String
    var text: String
    var style: TextStyle
    
    init(text: String = "", style: TextStyle = .paragraph) {
        self.id = UUID().uuidString
        self.text = text
        self.style = style
    }
        
    func asBlock() -> Block {
        .text(self)
    }
    
    func empty() -> TextBlock {
        TextBlock(style: style)
    }
}
