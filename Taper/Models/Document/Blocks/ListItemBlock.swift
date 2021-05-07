import Foundation

struct ListItemBlock: Hashable, Identifiable, TextBlockContent {
    let id: String
    
    var content: String = ""
    var number: Int = 1
    var style: ListItemStyle = .bulleted
    
    init(content: String = "", number: Int = 1, style: ListItemStyle) {
        self.id = UUID().uuidString
        self.content = content
        self.number = number
        self.style = style
    }
    
    func asBlock() -> Block {
        .listItem(self)
    }
    
    func empty() -> ListItemBlock {
        ListItemBlock(style: style)
    }
    
    func next() -> ListItemBlock {
        switch style {
        case .bulleted:
            return ListItemBlock(style: .bulleted)
        case .numbered:
            return ListItemBlock(number: number + 1, style: .numbered)
        }
    }
}
