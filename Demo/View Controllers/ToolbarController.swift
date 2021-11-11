import UIKit
import Pilcrow

enum ToolbarAction {
    case selectBlock(Block.Kind)
    case dismissKeyboard
}

protocol ToolbarDelegate: AnyObject {
    func toolbarDidTapButton(action: ToolbarAction)
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.heightAnchor.constraint(equalToConstant: Metrics.toolbarHeight),
            hStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Metrics.blockContentHorizontalPadding),
            hStack.topAnchor.constraint(equalTo: view.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addBlockKindButtons()
        addDismissKeyboardButton()
    }
    
    private func addBlockKindButtons() {
        for (index, kind) in Block.Kind.all.enumerated() {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.setImage(kind.image, for: .normal)
            button.tintColor = .black
            button.addTarget(self, action: #selector(handleBlockKindTap(_:)), for: .touchUpInside)
            addButtonToToolbar(button)
        }
    }
    
    private func addDismissKeyboardButton() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleDismissKeyboardButton), for: .touchUpInside)
        addButtonToToolbar(button)
    }
    
    private func addButtonToToolbar(_ button: UIButton) {
        hStack.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: Metrics.toolbarButtonSize.height),
            button.widthAnchor.constraint(equalToConstant: Metrics.toolbarButtonSize.width)
        ])
    }
    
    @objc private func handleBlockKindTap(_ button: UIButton) {
        let kind = Block.Kind.all[button.tag]
        delegate?.toolbarDidTapButton(action: .selectBlock(kind))
    }
    
    @objc private func handleDismissKeyboardButton() {
        delegate?.toolbarDidTapButton(action: .dismissKeyboard)
    }
    
    // MARK: - Views
    
    let view = UIInputView(frame: CGRect(x: 0, y: 0, width: 0, height: Metrics.toolbarHeight), inputViewStyle: .keyboard)
    
    private lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        view.alignment = .center
        return view
    }()
}
