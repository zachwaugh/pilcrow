import UIKit

struct TextBlockViewModel {
    let content: TextBlock
    
    var text: String {
        content.text
    }
    
    var textFont: UIFont {
        content.style.font
    }
}
