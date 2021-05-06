import UIKit

protocol TextCellDelegate: AnyObject {
    func textCellDidUpdateContent(cell: TextBlockCellView, content: String)
}

final class TextBlockCellView: UICollectionViewCell {
    weak var delegate: TextCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with block: TextBlock) {
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
        view.font = UIFont.systemFont(ofSize: 17)
        view.delegate = self
        
        return view
    }()
}

extension TextBlockCellView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textCellDidUpdateContent(cell: self, content: textView.text ?? "")
    }
}
