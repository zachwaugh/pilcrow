import UIKit

enum BlockKind: CaseIterable {
    case heading, paragraph
    case todo
    case bulletedListItem, numberedListItem
    
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
        }
    }
    
    var image: UIImage? {
        switch self {
        case .heading:
            return UIImage(systemName: "textformat.size", withConfiguration: nil)
        case .paragraph:
            return UIImage(systemName: "paragraphsign", withConfiguration: nil)
        case .todo:
            return UIImage(systemName: "checkmark.square", withConfiguration: nil)
        case .bulletedListItem:
            return UIImage(systemName: "list.bullet", withConfiguration: nil)
        case .numberedListItem:
            return UIImage(systemName: "list.number", withConfiguration: nil)
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
        }
    }
}
