import UIKit

struct ListItemBlockViewModel {
    let text: String
    let listItemLabelString: String
    
    var textFont: UIFont {
        TextStyle.paragraph.font
    }
}

extension ListItemBlockViewModel {
    init(content: BulletedListItemContent) {
        self.init(text: content.text, listItemLabelString: "•")
    }
    
    init(content: NumberedListItemContent) {
        self.init(text: content.text, listItemLabelString: "\(content.number).")
    }
}
