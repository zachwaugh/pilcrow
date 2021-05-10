import UIKit

final class QuoteBlockCellView: BaseTextCellView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: QuoteBlockViewModel) {
        quoteBorderView.backgroundColor = viewModel.borderColor
        textView.textColor = viewModel.textColor
        textView.font = viewModel.textFont
        textView.text = viewModel.text
    }
    
    private func setup() {
        contentView.addSubview(quoteBorderView)
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            quoteBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            quoteBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            quoteBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            quoteBorderView.widthAnchor.constraint(equalToConstant: Metrics.quoteBorderWidth),
            
            textView.leadingAnchor.constraint(equalTo: quoteBorderView.trailingAnchor, constant: Metrics.quoteBorderSpacing),
            textView.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor, constant: -Metrics.blockContentHorizontalPadding),
            textView.topAnchor.constraint(equalTo:  contentView.topAnchor, constant: Metrics.quoteContentVerticalPadding),
            textView.bottomAnchor.constraint(equalTo:  contentView.bottomAnchor, constant: -Metrics.quoteContentVerticalPadding),
        ])
    }
    
    // MARK: - Views
    
    private let quoteBorderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}
