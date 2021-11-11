import UIKit
import Pilcrow

extension Block.Kind {
    /// A custom "color" block provided by the application
    static let color = Block.Kind("color")
    
    static var all: [Block.Kind] {
        [.paragraph, .heading, .listItem, .todo, .quote, .divider, .color]
    }
    
    var title: String {
        switch self {
        case .todo:
            return "To do"
        case .listItem:
            return "List item"
//        case .bulletedListItem:
//            return "Bulleted List"
//        case .numberedListItem:
//            return "Numbered List"
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
        case .color:
            return UIImage(systemName: "paintpalette")
        default:
            print("[Pilcrow] *** error - no image provided for kind: \(self)")
            return nil
        }
    }
    
    var isText: Bool {
        !isDecorative
    }
    
    var isDecorative: Bool {
        switch self {
        case .divider, .color:
            return true
        default:
            return false
        }
    }
}
