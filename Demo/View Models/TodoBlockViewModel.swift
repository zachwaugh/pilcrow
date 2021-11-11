import UIKit
import Pilcrow

struct TodoBlockViewModel {
    let block: Block
    
    var isCompleted: Bool {
        block.isCompleted
    }
    
    var attributedText: NSAttributedString {
        NSAttributedString(string: block.content, attributes: isCompleted ? completedTextAttributes : defaultTextAttributes)
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
        isCompleted ? UIImage(named: "checked") : UIImage(named: "unchecked")
    }
}
