import Pilcrow

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif


/// Application Pilcrow extensions

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
            return rawValue.capitalized
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
    
    #if canImport(UIKit)
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
    #endif
}

extension Document {
    /// Test document contains a sample of all blocks
    static var test: Document {
        Document(blocks: [
            Block(content: "Heading", kind: .heading),
            Block(content: "Paragraph", kind: .paragraph),
            Block(content: "Bullet list item", kind: .paragraph, properties: ["type": "bullet"]),
            Block(content: "Ordered list item", kind: .paragraph, properties: ["type": "numbered", "index": "1"]),
            Block(content: "Bullet list item", kind: .listItem, properties: ["type": "bullet"]),
            Block(content: "Ordered list item", kind: .listItem, properties: ["type": "numbered", "index": "1"]),
            Block(content: "Paragraph that is much longer so it will wrap to multiple lines"),
            Block(content: "Todo", kind: .todo),
            Block(content: "Another paragraph"),
            Block(content: "Completed todo that is also much longer so we can test how it wraps", kind: .todo, properties: ["completed": "true"]),
            Block(content: "Final paragraph"),
            Block(content: "You miss 100% of the shots you don't take - Wayne Gretzky\n— Michael Scott", kind: .quote),
        ])
    }
}
