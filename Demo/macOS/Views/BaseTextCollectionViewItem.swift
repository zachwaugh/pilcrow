import AppKit
import Pilcrow

protocol TextCellDelegate: AnyObject {
    func textCellDidEdit(cell: NSCollectionViewItem, edit: TextEdit)
}

class BaseTextCollectionViewItem: NSCollectionViewItem {
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("text-item-identifier")

    weak var delegate: TextCellDelegate?
    
    func focus() {
        view.window?.makeFirstResponder(textView)
    }

    var hasFocus: Bool {
        textView.isFieldEditor
    }
    
    func configure(with block: Block) {
        switch block.kind {
        case .heading:
            textView.font = NSFont.systemFont(ofSize: 24, weight: .semibold)
            textView.textColor = .textColor
        case .paragraph:
            textView.font = NSFont.systemFont(ofSize: 15)
            textView.textColor = .textColor
        case .quote:
            textView.font = NSFont.systemFont(ofSize: 15)
            textView.textColor = .systemGray
        default:
            textView.font = NSFont.systemFont(ofSize: 15)
            textView.textColor = .textColor
        }
        
        var content = ""
        
        switch block.kind {
        case .todo:
            content = "☑ \(block.content)"
        case .listItem:
            content = "• \(block.content)"
        case .quote:
            content = ">  \(block.content)"
        default:
            content = block.content
        }
        
        textView.string = content
    }
    
    //lazy var toolbarController = ToolbarController()
    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 500, height: 20))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Views
    
    private func setupViews() {
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    lazy var textView: TextView = {
        let textView = TextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.wantsLayer = true
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.allowsDocumentBackgroundColorChange = false
        textView.font = NSFont.systemFont(ofSize: 17)
        textView.allowsUndo = true
//
//        textView.layer?.borderColor = NSColor.systemYellow.withAlphaComponent(0.1).cgColor
//        textView.layer?.borderWidth = 1
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        textView.defaultParagraphStyle = paragraphStyle
        return textView
    }()
}

extension BaseTextCollectionViewItem: NSTextViewDelegate {
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

final class TextView: NSTextView {
    override var intrinsicContentSize: NSSize {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return .zero
        }
        
        layoutManager.ensureLayout(for: textContainer)
        let size = layoutManager.usedRect(for: textContainer)
        print("text view size: \(size) for \(string)")
        return NSSize(width: NSView.noIntrinsicMetric, height: ceil(size.height))
    }
    
    override var frame: NSRect {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var string: String {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
    }
}
