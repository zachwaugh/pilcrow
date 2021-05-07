import Foundation

struct TextBlock: Hashable, Identifiable, Codable, TextBlockContent {
    let id: String
    var content: String
    var style: TextStyle
    
    init(content: String = "", style: TextStyle = .paragraph) {
        self.id = UUID().uuidString
        self.content = content
        self.style = style
    }
        
    func asBlock() -> Block {
        .text(self)
    }
    
    func empty() -> TextBlock {
        TextBlock(style: style)
    }
}
