import AppKit

protocol TodoCellDelegate: TextCellDelegate {
    func todoCellDidToggleCheckBox(cell: TodoCellView)
}

final class TodoCellView: BaseTextCellView {
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("todo-cell-identifier")

    weak var todoDelegate: TodoCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func configure(with viewModel: TodoBlockViewModel) {
        checkboxButton.state = viewModel.isCompleted ? .on : .off
        textView.string = viewModel.text
        //textView.textStorage?.setAttributedString(viewModel.attributedText)
        //textView.typingAttributes = viewModel.isCompleted ? viewModel.completedTextAttributes : viewModel.defaultTextAttributes
    }

    @objc private func toggleCheckbox(_ sender: Any) {
        todoDelegate?.todoCellDidToggleCheckBox(cell: self)
    }
    
    private func setupViews() {
        view.addSubview(checkboxButton)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            checkboxButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),

            textView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo:  view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo:  view.bottomAnchor),
        ])
    }

    // MARK: - Views

    private lazy var checkboxButton: NSButton = {
        let button = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleCheckbox(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
}
