import UIKit

struct QuoteBlockViewModel {
    let content: QuoteBlock
    
    var text: String {
        content.text
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
