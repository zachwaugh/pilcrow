import Foundation

struct NumberedListItemContent: Hashable, Identifiable, TextBlockContent {
    let id: String
    
    var text: String = ""
    var number: Int = 1
    
    init(text: String = "", number: Int = 1) {
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
        NumberedListItemContent(number: number + 1)
    }
}

