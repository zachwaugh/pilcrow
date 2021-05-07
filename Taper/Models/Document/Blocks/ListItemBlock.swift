import Foundation

struct ListItemBlock: Hashable, TextBlockable {
    let identifier = UUID()
    var content: String = ""
    var style: ListItemStyle = .bullet
    
    func asBlock() -> Block {
        .listItem(self)
    }
    
    func empty() -> ListItemBlock {
        ListItemBlock(style: style)
    }
    
    func next() -> ListItemBlock {
        switch style {
        case .bullet:
            return ListItemBlock(style: .bullet)
        case .number(let number):
            return ListItemBlock(style: .number(number + 1))
        }
    }
}
