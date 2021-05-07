import Foundation

struct TextBlock: Hashable, TextBlockable {
    let identifier = UUID()
    var content: String = ""
    var style: TextStyle = .paragraph
        
    func asBlock() -> Block {
        .text(self)
    }
    
    func empty() -> TextBlock {
        TextBlock(style: style)
    }
}
