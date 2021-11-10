import Foundation

//extension Block {
//    enum Kind: CaseIterable, CodingKey {
//        case heading, paragraph, quote
//        case todo, bulletedListItem, numberedListItem
//        case divider
//
//        /// True for list items and other types of text content that can be converted
//        /// to a plain paragraph
//        var isDecoratedTextContent: Bool {
//            switch self {
//            case .bulletedListItem, .numberedListItem, .todo, .quote:
//                return true
//            default:
//                return false
//            }
//        }
//
//        func makeEmptyBlockContent() -> BlockContent {
//            blockContentType.init()
//        }
//
//        var blockContentType: BlockContent.Type {
//            switch self {
//            case .heading:
//                return HeadingContent.self
//            case .paragraph:
//                return ParagraphContent.self
//            case .quote:
//                return QuoteContent.self
//            case .todo:
//                return TodoContent.self
//            case .bulletedListItem:
//                return BulletedListItemContent.self
//            case .numberedListItem:
//                return NumberedListItemContent.self
//            case .divider:
//                return DividerContent.self
//            }
//        }
//
//        var textBlockContentType: TextBlockContent.Type? {
//            blockContentType as? TextBlockContent.Type
//        }
//
//        func makeEmptyBlock() -> Block {
//            makeEmptyBlockContent().asBlock()
//        }
//    }
//}
