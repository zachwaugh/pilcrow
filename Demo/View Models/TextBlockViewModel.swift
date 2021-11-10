import UIKit

struct TextBlockViewModel {
    let content: TextBlockContent
    let style: TextStyle
    
    var text: String {
        content.text
    }
    
    var textFont: UIFont {
        style.font
    }
}

extension TextBlockViewModel {
    init(content: ParagraphContent) {
        self.init(content: content, style: .paragraph)
    }
    
    init(content: HeadingContent) {
        self.init(content: content, style: .heading)
    }
}
