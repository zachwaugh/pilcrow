import UIKit

protocol TodoCellDelegate: TextCellDelegate {
    func todoCellDidToggleCheckBox(cell: TodoBlockCellView)
}

final class TodoBlockCellView: BaseTextCellView {
    weak var todoDelegate: TodoCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: TodoBlockViewModel) {
        checkboxButton.setImage(viewModel.checkboxImage, for: .normal)
        textView.attributedText = viewModel.attributedText
        textView.typingAttributes = viewModel.defaultTextAttributes
    }
    
    @objc private func toggleCheckbox(_ sender: Any) {
        todoDelegate?.todoCellDidToggleCheckBox(cell: self)
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
}
