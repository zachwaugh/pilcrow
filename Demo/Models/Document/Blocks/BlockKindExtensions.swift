import UIKit
import Pilcrow

extension Block.Kind {
    static var all: [Block.Kind] {
        [.paragraph, .heading, .listItem, .todo, .quote, .divider]
    }
    
    var title: String {
        switch self {
        case .heading:
            return "Heading"
        case .paragraph:
            return "Paragraph"
        case .todo:
            return "To do"
        case .listItem:
            return "List item"
//        case .bulletedListItem:
//            return "Bulleted List"
//        case .numberedListItem:
//            return "Numbered List"
        case .quote:
            return "Quote"
        case .divider:
            return "Divider"
        default:
            return name.capitalized
        }
    }
    
    var image: UIImage? {
        switch self {
        case .heading:
            return UIImage(systemName: "textformat.size")
        case .paragraph:
            return UIImage(systemName: "paragraphsign")
        case .todo:
            return UIImage(systemName: "checkmark.square")
        case .listItem:
            return UIImage(systemName: "list.bullet")
//        case .bulletedListItem:
//            return UIImage(systemName: "list.bullet")
//        case .numberedListItem:
//            return UIImage(systemName: "list.number")
        case .quote:
            return UIImage(systemName: "text.quote")
        case .divider:
            return UIImage(systemName: "divide")
        default:
            print("[Pilcrow] *** error - no image provided for kind: \(self)")
            return nil
        }
    }
}
