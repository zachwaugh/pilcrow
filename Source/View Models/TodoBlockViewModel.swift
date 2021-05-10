import UIKit

struct TodoBlockViewModel {
    let content: TodoBlock
    
    var attributedText: NSAttributedString {
        NSAttributedString(string: content.text, attributes: content.completed ? completedTextAttributes : defaultTextAttributes)
    }
    
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: TextStyle.paragraph.font,
            .foregroundColor: UIColor.label
        ]
    }
    
    var completedTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: TextStyle.paragraph.font,
            .foregroundColor: UIColor.separator,
            .strikethroughColor: UIColor.separator,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    var checkboxImage: UIImage? {
        content.completed ? UIImage(named: "checked") : UIImage(named: "unchecked")
    }
}
