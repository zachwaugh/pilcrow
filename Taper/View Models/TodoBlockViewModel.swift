import UIKit

struct TodoBlockViewModel {
    let content: TodoBlock
    
    var attributedText: NSAttributedString {
        var attributes = defaultTextAttributes
        
        if content.completed {
            attributes[.foregroundColor] = UIColor.separator
            attributes[.strikethroughColor] = UIColor.separator
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        return NSAttributedString(string: content.text, attributes: attributes)
    }
    
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label
        ]
    }
    
    var checkboxImage: UIImage? {
        content.completed ? UIImage(named: "checked") : UIImage(named: "unchecked")
    }
}
