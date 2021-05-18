import UIKit

enum BlockDecodingError: Error {
    case invalidData
}

// TODO: there is a lot of redundancy here we should be able to refactor out
// but for now it's simplest to keep everything 1:1 while I figure out how I want it all to work
enum Block: Hashable {
    case heading(HeadingContent)
    case paragraph(ParagraphContent)
    case quote(QuoteContent)
    
    case todo(TodoContent)
    
    case bulletedListItem(BulletedListItemContent)
    case numberedListItem(NumberedListItemContent)
    
    case divider(DividerContent)
    
    var content: BlockContent {
        switch self {
        case .heading(let content):
            return content
        case .paragraph(let content):
            return content
        case .quote(let content):
            return content
        case .todo(let content):
            return content
        case .bulletedListItem(let content):
            return content
        case .numberedListItem(let content):
            return content
        case .divider(let content):
            return content
        }
    }
    
    var kind: Kind {
        switch self {
        case .heading(_):
            return .heading
        case .paragraph(_):
            return .paragraph
        case .todo(_):
            return .todo
        case .bulletedListItem(_):
            return .bulletedListItem
        case .numberedListItem(_):
            return .numberedListItem
        case .quote(_):
            return .quote
        case .divider(_):
            return .divider
        }
    }
}

extension Block {
    enum Kind: CaseIterable, CodingKey {
        case heading, paragraph, quote
        case todo, bulletedListItem, numberedListItem
        case divider
        
        func makeEmptyBlockContent() -> BlockContent {
            switch self {
            case .heading:
                return HeadingContent()
            case .paragraph:
                return ParagraphContent()
            case .quote:
                return QuoteContent()
            case .todo:
                return TodoContent()
            case .bulletedListItem:
                return BulletedListItemContent()
            case .numberedListItem:
                return NumberedListItemContent()
            case .divider:
                return DividerContent()
            }
        }
        
        func makeEmptyBlock() -> Block {
            makeEmptyBlockContent().asBlock()
        }
    }
}

extension Block: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Block.Kind.self)
                
        if let content = try container.decodeIfPresent(ParagraphContent.self, forKey: .paragraph) {
            self = .paragraph(content)
        } else if let content = try container.decodeIfPresent(HeadingContent.self, forKey: .heading) {
            self = .heading(content)
        } else if let content = try container.decodeIfPresent(QuoteContent.self, forKey: .quote) {
            self = .quote(content)
        } else if let content = try container.decodeIfPresent(TodoContent.self, forKey: .todo) {
            self = .todo(content)
        } else if let content = try container.decodeIfPresent(BulletedListItemContent.self, forKey: .bulletedListItem) {
            self = .bulletedListItem(content)
        } else if let content = try container.decodeIfPresent(NumberedListItemContent.self, forKey: .numberedListItem) {
            self = .numberedListItem(content)
        } else if let content = try container.decodeIfPresent(DividerContent.self, forKey: .divider) {
            self = .divider(content)
        } else {
            throw BlockDecodingError.invalidData
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Block.Kind.self)
                
        switch self {
        case .heading(let content):
            try container.encode(content, forKey: kind)
        case .paragraph(let content):
            try container.encode(content, forKey: kind)
        case .quote(let content):
            try container.encode(content, forKey: kind)
        case .todo(let content):
            try container.encode(content, forKey: kind)
        case .bulletedListItem(let content):
            try container.encode(content, forKey: kind)
        case .numberedListItem(let content):
            try container.encode(content, forKey: kind)
        case .divider(let content):
            try container.encode(content, forKey: kind)
        }
    }
}
