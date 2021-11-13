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
        print("[BaseTextCellView] viewDidLoad: \(self)")

        view.wantsLayer = true
        view.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        view.layer?.borderWidth = 1
    }
    
    override func loadView() {
        // Has to be non-zero or crashes
        view = NSView(frame: CGRect(x: 0, y: 0, width: 500, height: 20))
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
        
        //textView.isVerticallyResizable = true
        //textView.textContainer?.heightTracksTextView = true
        
        //textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        //textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        textView.layoutManager?.delegate = textView
        
        textView.backgroundColor = NSColor.systemYellow.withAlphaComponent(0.1)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
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
}
