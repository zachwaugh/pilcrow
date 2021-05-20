import UIKit

protocol ToolbarDelegate: AnyObject {
    func toolbarDidTapButtonOfKind(_ kind: Block.Kind)
}

final class ToolbarController {
    weak var delegate: ToolbarDelegate?
    
    init() {
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.heightAnchor.constraint(equalToConstant: Metrics.toolbarHeight),
            hStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            hStack.topAnchor.constraint(equalTo: view.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addButtons()
    }
    
    private func addButtons() {
        for (index, kind) in Block.Kind.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.setImage(kind.image, for: .normal)
            button.tintColor = .black
            button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            hStack.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    
    @objc private func handleTap(_ button: UIButton) {
        delegate?.toolbarDidTapButtonOfKind(Block.Kind.allCases[button.tag])
    }
    
    // MARK: - Views
    
    let view = UIInputView(frame: CGRect(x: 0, y: 0, width: 0, height: Metrics.toolbarHeight), inputViewStyle: .keyboard)
    
    private lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        return view
    }()
}
