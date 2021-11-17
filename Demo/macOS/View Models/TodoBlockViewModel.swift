import AppKit
import Pilcrow

struct TodoBlockViewModel {
    let block: Block
    
    var isCompleted: Bool {
        block.isCompleted
    }
    
    var text: String {
        block.content
    }
    
    var attributedText: NSAttributedString {
        NSAttributedString(string: block.content, attributes: isCompleted ? completedTextAttributes : defaultTextAttributes)
    }
    
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.systemFont(ofSize: 15),
            .foregroundColor: NSColor.textColor
        ]
    }
    
    var completedTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.systemFont(ofSize: 15),
            .foregroundColor: NSColor.systemGray,
            .strikethroughColor: NSColor.systemGray,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    var checkboxImage: NSImage? {
        isCompleted ? NSImage(systemSymbolName: "checked", accessibilityDescription: nil) : NSImage(systemSymbolName: "unchecked", accessibilityDescription: nil)
    }
}
