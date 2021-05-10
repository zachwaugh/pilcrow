import UIKit

enum BlockDecodingError: Error {
    case invalidData
}

enum Block: Hashable {
    case text(TextBlock)
    case todo(TodoBlock)
    case listItem(ListItemBlock)
    
    var content: BlockContent {
        switch self {
        case .text(let content):
            return content
        case .todo(let content):
            return content
        case .listItem(let content):
            return content
        }
    }
}

extension Block: Codable {
    private enum CodingKeys: CodingKey {
        case text, todo, listItem
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let content = try container.decodeIfPresent(TextBlock.self, forKey: .text) {
            self = .text(content)
        } else if let content = try container.decodeIfPresent(TodoBlock.self, forKey: .todo) {
            self = .todo(content)
        } else if let content = try container.decodeIfPresent(ListItemBlock.self, forKey: .listItem) {
            self = .listItem(content)
        } else {
            throw BlockDecodingError.invalidData
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let content):
            try container.encode(content, forKey: .text)
        case .todo(let content):
            try container.encode(content, forKey: .todo)
        case .listItem(let content):
            try container.encode(content, forKey: .listItem)
        }
    }
}
