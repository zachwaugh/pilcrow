import Foundation

extension NSRange {
    public var isCollapsed: Bool {
        length == 0
    }
    
    public var isAtBeginning: Bool {
        location == 0
    }
    
    public func isAtEnd(of string: String) -> Bool {
        location >= string.utf16.count
    }
}
