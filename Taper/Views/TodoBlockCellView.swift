import UIKit

protocol TodoCellDelegate: AnyObject {
    func todoCellDidToggleCheckBox(cell: TodoBlockCellView)
    func todoCellDidUpdateContent(cell: TodoBlockCellView, content: String)
}

final class TodoBlockCellView: UICollectionViewCell {
    weak var delegate: TodoCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with todo: TodoBlock) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        
        let typingAttributes = attributes
        
        if todo.completed {
            checkboxButton.setImage(UIImage(named: "checked"), for: .normal)
            attributes[.foregroundColor] = UIColor.lightGray
            attributes[.strikethroughColor] = UIColor.lightGray
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        } else {
            checkboxButton.setImage(UIImage(named: "unchecked"), for: .normal)
        }
        
        textView.attributedText = NSAttributedString(string: todo.content, attributes: attributes)
        textView.typingAttributes = typingAttributes
    }
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    @objc private func toggleCheckbox(_ sender: Any) {
        delegate?.todoCellDidToggleCheckBox(cell: self)
    }
    
    private func setup() {
        setupViews()
        checkboxButton.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
    }
    
    private func setupViews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),

            textView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: checkboxButton.topAnchor, constant: 4),
            textView.bottomAnchor.constraint(equalTo:  contentView.bottomAnchor),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 28)
        ])
    }
    
    // MARK: - Views
    
    private let checkboxButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .gray
        return view
    }()
    
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

extension TodoBlockCellView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.todoCellDidUpdateContent(cell: self, content: textView.text ?? "")
    }
}
