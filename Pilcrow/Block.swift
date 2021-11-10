import Foundation

public struct Block: Identifiable, Hashable, Codable {
    public typealias Properties = [String: String]
    
    public let id: String
    public let content: String
    public let kind: Kind
    public let properties: Properties
    
    public init(id: String = UUID().uuidString, content: String, kind: Kind = .paragraph, properties: Properties = [:]) {
        self.id = id
        self.content = content
        self.kind = kind
        self.properties = properties
    }
    
    public subscript(key: String) -> String? {
        properties[key]
    }
}

extension Block {
    public struct Kind: Hashable, Codable {
        public let name: String
        
        public init(_ name: String) {
            self.name = name
        }
        
        public static let paragraph = Kind("paragraph")
    }
}
