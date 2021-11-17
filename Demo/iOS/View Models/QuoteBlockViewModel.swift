import UIKit
import Pilcrow

struct QuoteBlockViewModel {
    let block: Block
    
    var text: String {
        block.content
    }
    
    var textColor: UIColor {
        .systemGray
    }
    
    var textFont: UIFont {
        TextStyle.paragraph.font
    }
    
    var borderColor: UIColor {
        .systemGray2
    }
    
    var borderWidth: CGFloat {
        5
    }
}
