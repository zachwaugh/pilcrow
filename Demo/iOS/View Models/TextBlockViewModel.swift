import UIKit
import Pilcrow

struct TextBlockViewModel {
    let block: Block
    let style: TextStyle
    
    var text: String {
        block.content
    }
    
    var textFont: UIFont {
        style.font
    }
}
