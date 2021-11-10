import Foundation

public struct Block: Identifiable, Hashable, Codable {
    public typealias Properties = [String: String]
    
    public let id: String
    public var content: String
    public var kind: Kind
    public var properties: Properties
    
    public init(id: String = UUID().uuidString, content: String = "", kind: Kind = .paragraph, properties: Properties = [:]) {
        self.id = id
        self.content = content
        self.kind = kind
        self.properties = properties
    }
    
    /// Returns
    public func next() -> Block {
        Block(kind: kind, properties: properties)
    }
    
    /// Convenience method for returning property for key if any
    public subscript(key: String) -> String? {
        properties[key]
    }
}
