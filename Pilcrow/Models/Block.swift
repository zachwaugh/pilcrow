import Foundation

public struct Block: Identifiable, Hashable, Codable {
    public typealias Properties = [String: String]
    
    public let id: String
    public var content: String
    public var kind: Kind
    public var properties: Properties
    
    public init(
        id: String = UUID().uuidString,
        content: String = "",
        kind: Kind = .paragraph,
        properties: Properties = [:]
    ) {
        self.id = id
        self.content = content
        self.kind = kind
        self.properties = properties
    }
    
    /// Returns an appropriate block as successor to this one
    public func next() -> Block {
        Block(content: "", kind: kind, properties: properties)
    }
    
    /// Convenience method for getting/setting properties
    public subscript(key: String) -> String? {
        get {
            properties[key]
        }
        set {
            properties[key] = newValue
        }
    }
}

// MARK: - Todos
extension Block {
    public static let completedKey = "completed"
    
    public var isCompleted: Bool {
        self[Self.completedKey] == "true"
    }
    
    public mutating func toggleCompletion() {
        if isCompleted {
            markAsUncompleted()
        } else {
            markAsCompleted()
        }
    }
    
    public mutating func markAsCompleted() {
        self[Self.completedKey] = "true"
    }
    
    public mutating func markAsUncompleted() {
        self[Self.completedKey] = "false"
    }
}
