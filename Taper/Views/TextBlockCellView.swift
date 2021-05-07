import UIKit

protocol Focusable {
    func focus()
}

enum TextEdit {
    case delete, enter
}

protocol TextCellDelegate: AnyObject {
    func textCellDidUpdateContent(cell: UICollectionViewCell, content: String)
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit)
}

final class TextBlockCellView: UICollectionViewCell, Focusable {
    weak var delegate: TextCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with block: TextBlock) {
        textView.font = block.style.font
        textView.text = block.content
    }
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    private func setup() {
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo:  contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo:  contentView.bottomAnchor),
        ])
    }
    
    // MARK: - Views
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.delegate = self
        
        return view
    }()
}

extension TextBlockCellView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textCellDidUpdateContent(cell: self, content: textView.text ?? "")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("change - range: \(range), text: \(text)")
        
        if text == "\n" {
            delegate?.textCellDidEdit(cell: self, edit: .enter)
            return false
        } else if text.isEmpty, range.location == 0, range.length == 0 {
            delegate?.textCellDidEdit(cell: self, edit: .delete)
            return false
        } else {
            return true
        }
    }
}
