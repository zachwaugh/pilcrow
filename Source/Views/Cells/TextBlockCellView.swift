import UIKit

final class TextBlockCellView: BaseTextCellView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: TextBlockViewModel) {
        textView.font = viewModel.textFont
        textView.text = viewModel.text
    }

    private func setup() {
        contentView.addSubview(textView)
       
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.blockContentHorizontalPadding),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.blockContentVerticalPadding),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.blockContentVerticalPadding),
       ])
   }
}
