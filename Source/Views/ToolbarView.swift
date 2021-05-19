import UIKit

final class ToolbarView: UIInputView {
    init(frame: CGRect) {
        super.init(frame: frame, inputViewStyle: .keyboard)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        Block.Kind.allCases.forEach { kind in
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(kind.image, for: .normal)
            button.tintColor = .black
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            hStack.addArrangedSubview(button)
        }
        
        addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Views
    
    private lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        return view
    }()
}
