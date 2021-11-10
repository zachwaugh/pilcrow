import Foundation

extension Block {
    public struct Kind: Hashable, Codable {
        public let name: String
        
        public init(_ name: String) {
            self.name = name
        }
    }
}

public extension Block.Kind {
    static let paragraph = Block.Kind("paragraph")
    static let heading = Block.Kind("heading")
    static let quote = Block.Kind("quote")
    static let todo = Block.Kind("todo")
    static let listItem = Block.Kind("listItem")
    static let divider = Block.Kind("divider")
}
