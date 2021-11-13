import AppKit
import Pilcrow

final class TextCellView: BaseTextCellView {
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("pilcrow.text-cell-identifier")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        textView.backgroundColor = NSColor.systemYellow.withAlphaComponent(0.1)
    }
    
    func configure(with block: Block) {
        switch block.kind {
        case .heading:
            textView.font = NSFont.systemFont(ofSize: 32, weight: .semibold)
            textView.textColor = .textColor
        default:
            textView.font = NSFont.systemFont(ofSize: 15)
            textView.textColor = .textColor
        }
        
        textView.string = block.content
    }
    
    // MARK: - Views
    
    private func setupViews() {
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
