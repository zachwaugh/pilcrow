import UIKit

final class TodoBlockCellView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with block: TodoBlock) {
        textView.text = block.content
        checkboxView.image = block.completed ? UIImage(systemName: "checkmark") : nil
    }
    
    private func setup() {
        contentView.addSubview(checkboxView)
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            checkboxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkboxView.topAnchor.constraint(equalTo: contentView.topAnchor),
            checkboxView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            checkboxView.heightAnchor.constraint(equalToConstant: 30),
            checkboxView.widthAnchor.constraint(equalToConstant: 30),

            textView.leadingAnchor.constraint(equalTo: checkboxView.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo:  contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo:  contentView.bottomAnchor),
        ])
    }
    
    // MARK: - Views
    
    private let checkboxView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.font = UIFont.systemFont(ofSize: 17)
        return view
    }()
}
