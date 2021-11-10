import UIKit

extension Block.Kind {
    var title: String {
        switch self {
        case .heading:
            return "Heading"
        case .paragraph:
            return "Paragraph"
        case .todo:
            return "To do"
        case .bulletedListItem:
            return "Bulleted List"
        case .numberedListItem:
            return "Numbered List"
        case .quote:
            return "Quote"
        case .divider:
            return "Divider"
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
        case .bulletedListItem:
            return UIImage(systemName: "list.bullet")
        case .numberedListItem:
            return UIImage(systemName: "list.number")
        case .quote:
            return UIImage(systemName: "text.quote")
        case .divider:
            return UIImage(systemName: "divide")
        }
    }
    
    var cellClass: UICollectionViewCell.Type {
        switch self {
        case .heading, .paragraph:
            return TextBlockCellView.self
        case .todo:
            return TodoBlockCellView.self
        case .bulletedListItem, .numberedListItem:
            return ListItemBlockCellView.self
        case .quote:
            return QuoteBlockCellView.self
        case .divider:
            return DividerBlockCellView.self
        }
    }
}
