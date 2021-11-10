import Foundation

public struct Block: Identifiable, Hashable, Codable {
    public let id: String
    public let content: String
    public let kind: Kind
    //public let properties: [String: AnyHashable]
    
    public init(id: String = UUID().uuidString, content: String, kind: Kind = .paragraph) {
        self.id = id
        self.content = content
        self.kind = kind
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
