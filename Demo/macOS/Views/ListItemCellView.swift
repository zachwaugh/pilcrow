import AppKit
import Pilcrow

struct ListItemBlockViewModel {
    let block: Block
    var listItemLabelString: String = "•"
    
    var text: String {
        block.content
    }
}

final class ListItemCellView: BaseTextCellView {
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("list-item-cell-identifier")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        //textView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
    }

    func configure(with viewModel: ListItemBlockViewModel) {
        itemLabel.stringValue = viewModel.listItemLabelString
        textView.string = viewModel.text
    }

    private func setupViews() {
        view.addSubview(textView)
        view.addSubview(itemLabel)

        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            itemLabel.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: itemLabel.trailingAnchor, constant: 4),

            textView.trailingAnchor.constraint(equalTo:  view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Views

    private lazy var itemLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 15)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
}
