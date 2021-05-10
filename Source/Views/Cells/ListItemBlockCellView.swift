import UIKit

final class ListItemBlockCellView: BaseTextCellView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ListItemBlockViewModel) {
        listItemLabel.text = viewModel.listItemLabelString
        textView.font = viewModel.textFont
        textView.text = viewModel.text
    }
    
    private func setup() {
        contentView.addSubview(listItemLabel)
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            listItemLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            listItemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            textView.leadingAnchor.constraint(equalTo: listItemLabel.trailingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo:  contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo:  contentView.bottomAnchor),
        ])
    }
    
    // MARK: - Views
    
    private let listItemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
}
