import AppKit
import Pilcrow

protocol TextCellDelegate: AnyObject {
    func textCellDidEdit(cell: NSCollectionViewItem, edit: TextEdit)
}

class BaseTextCellView: NSCollectionViewItem {
    weak var delegate: TextCellDelegate?
    
    func focus() {
        view.window?.makeFirstResponder(textView)
    }

    var hasFocus: Bool {
        textView.isFieldEditor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
//        view.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
//        view.layer?.borderWidth = 1
    }
    
    override func loadView() {
        view = NSView() // CGRect(x: 0, y: 0, width: 500, height: 20))
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        textView.invalidateIntrinsicContentSize()
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
    
    lazy var textView: TextView = {
        let textView = TextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.allowsDocumentBackgroundColorChange = false
        textView.font = NSFont.systemFont(ofSize: 15)
        textView.allowsUndo = true
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        textView.defaultParagraphStyle = paragraphStyle
        
        return textView
    }()
}

extension BaseTextCellView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        delegate?.textCellDidEdit(cell: self, edit: .update(textView.string))
    }

    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        print("textView: doCommandBy: \(commandSelector)")
        
        if commandSelector == #selector(deleteBackward(_:)) && textView.string.isEmpty {
            delegate?.textCellDidEdit(cell: self, edit: .deleteAtBeginning)
            return true
        } else if commandSelector == #selector(insertNewline(_:)) {
            delegate?.textCellDidEdit(cell: self, edit: .insertNewline)
            return true
        } else {
            return false
        }
    }
    
    private var isEmpty: Bool {
        textView.string.isEmpty
    }
    
    private var isCollapsedCursorAtBeginning: Bool {
        let range = textView.selectedRange()
        return range.isCollapsed && range.isAtBeginning
    }
    
    private var isCursorAtEnd: Bool {
        let range = textView.selectedRange()
        return range.isCollapsed && range.isAtEnd(of: textView.string)
    }
}

