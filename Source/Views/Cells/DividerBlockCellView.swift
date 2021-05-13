import UIKit

final class DividerBlockCellView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: DividerBlockViewModel) {
        dividerView.backgroundColor = viewModel.backgroundColor
    }
    
    private func setup() {
        contentView.addSubview(dividerView)
        
        let widthConstraint = dividerView.widthAnchor.constraint(equalToConstant: Metrics.dividerMaxWidth)
        widthConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Metrics.dividerVerticalSpacing),
            dividerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Metrics.dividerVerticalSpacing),
            dividerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dividerView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            dividerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            widthConstraint,
            dividerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            dividerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Metrics.blockContentHorizontalPadding),

        ])
    }
    
    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}
