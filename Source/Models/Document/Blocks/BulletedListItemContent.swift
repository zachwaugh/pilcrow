import Foundation

struct BulletedListItemContent: Hashable, Identifiable, TextBlockContent {
    let id: String
    var text: String = ""
    
    init(text: String = "") {
        self.id = UUID().uuidString
        self.text = text
    }
    
    func asBlock() -> Block {
        .bulletedListItem(self)
    }
    
    func empty() -> BulletedListItemContent {
        BulletedListItemContent()
    }
}
