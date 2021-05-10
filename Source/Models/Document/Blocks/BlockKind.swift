import UIKit

enum BlockKind: CaseIterable {
    case heading, paragraph
    case todo
    case bulletedListItem, numberedListItem
    case quote
    
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
        }
    }
    
    var cellClass: UICollectionViewCell.Type {
        switch self {
        case .heading:
            return TextBlockCellView.self
        case .paragraph:
            return TextBlockCellView.self
        case .todo:
            return TodoBlockCellView.self
        case .bulletedListItem:
            return ListItemBlockCellView.self
        case .numberedListItem:
            return ListItemBlockCellView.self
        case .quote:
            return QuoteBlockCellView.self
        }
    }
}
