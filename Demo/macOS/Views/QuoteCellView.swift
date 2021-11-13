import AppKit
import Pilcrow

struct QuoteBlockViewModel {
    let block: Block
    
    var text: String {
        block.content
    }
}

final class QuoteCellView: BaseTextCellView {
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("quote-cell-identifier")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func configure(with viewModel: QuoteBlockViewModel) {
        textView.string = viewModel.text
    }

    private func setupViews() {
        textView.textColor = .systemGray
        
        view.addSubview(border)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.topAnchor.constraint(equalTo: view.topAnchor),
            border.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            border.widthAnchor.constraint(equalToConstant: 4),

            textView.leadingAnchor.constraint(equalTo: border.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo:  view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            textView.bottomAnchor.constraint(equalTo:  view.bottomAnchor, constant: -4),
        ])
    }

    // MARK: - Views

    private lazy var border: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemGray.cgColor
        return view
    }()
}
