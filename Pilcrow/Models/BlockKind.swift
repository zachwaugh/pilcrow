import Foundation

extension Block {
    public struct Kind: Hashable, Equatable, Codable, RawRepresentable {
        public typealias RawValue = String
        
        public let rawValue: RawValue
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
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
