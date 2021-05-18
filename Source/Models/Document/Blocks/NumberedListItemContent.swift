import Foundation

struct NumberedListItemContent: Hashable, Identifiable, TextBlockContent {
    let id: String
    var text: String
    var number: Int
    
    init() {
        self.init(text: "")
    }
    
    init(text: String) {
        self.init(text: text, number: 1)
    }
    
    init(text: String, number: Int) {
        self.id = UUID().uuidString
        self.text = text
        self.number = number
    }
    
    func asBlock() -> Block {
        .numberedListItem(self)
    }
    
    func empty() -> NumberedListItemContent {
        NumberedListItemContent()
    }
    
    func next() -> NumberedListItemContent {
        NumberedListItemContent(text: "", number: number + 1)
    }
}
