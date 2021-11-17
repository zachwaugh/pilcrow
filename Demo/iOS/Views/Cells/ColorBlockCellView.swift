import UIKit

final class ColorBlockCellView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ColorBlockViewModel) {
        backgroundColor = viewModel.backgroundColor
    }
    
    private func setup() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Metrics.colorBlockHeight)
        ])
    }
}
