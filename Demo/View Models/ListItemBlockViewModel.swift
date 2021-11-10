import UIKit
import Pilcrow

struct ListItemBlockViewModel {
    let block: Block
    let listItemLabelString: String
    
    var text: String {
        block.content
    }
    
    var textFont: UIFont {
        TextStyle.paragraph.font
    }
}

//extension ListItemBlockViewModel {
//    init(content: BulletedListItemContent) {
//        self.init(text: content.text, listItemLabelString: "•")
//    }
//
//    init(content: NumberedListItemContent) {
//        self.init(text: content.text, listItemLabelString: "\(content.number).")
//    }
//}
