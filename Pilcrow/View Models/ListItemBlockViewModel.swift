import UIKit

struct ListItemBlockViewModel {
    let content: ListItemBlock
    
    var listItemLabelString: String {
        switch content.style {
        case .bulleted:
            return "•"
        case .numbered:
            return "\(content.number)."
        }
    }
    
    var text: String {
        content.text
    }
    
    var textFont: UIFont {
        TextStyle.paragraph.font
    }
}
