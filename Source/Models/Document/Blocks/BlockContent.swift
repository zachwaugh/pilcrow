import Foundation

protocol BlockContent: Codable {
    var isEmpty: Bool { get }

    func asBlock() -> Block
    func empty() -> Self
    func next() -> BlockContent
}

extension BlockContent {
    var isEmpty: Bool {
        true
    }
    
    func next() -> BlockContent {
        empty()
    }
}

protocol TextBlockContent: BlockContent {
    var text: String { get set }
}

extension TextBlockContent {
    var isEmpty: Bool {
        text.isEmpty
    }
}
