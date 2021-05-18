import Foundation

struct HeadingContent: Hashable, Identifiable, Codable, TextBlockContent {
    let id: String
    var text: String
    
    init(text: String = "") {
        self.id = UUID().uuidString
        self.text = text
    }
        
    func asBlock() -> Block {
        .heading(self)
    }
    
    func empty() -> HeadingContent {
        HeadingContent()
    }
    
    func next() -> BlockContent {
        ParagraphContent()
    }
}
