import UIKit

protocol TextCellDelegate: AnyObject {
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit)
}

class BaseTextCellView: UICollectionViewCell, FocusableView {
    weak var delegate: TextCellDelegate?
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    var hasFocus: Bool {
        textView.isFirstResponder
    }

    // MARK: - Views
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.delegate = self
        view.keyboardDismissMode = .interactive
        
        return view
    }()
}

extension BaseTextCellView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textCellDidEdit(cell: self, edit: .update(textView.text ?? ""))
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.textCellDidEdit(cell: self, edit: .insertNewline)
            return false
        } else if text.isEmpty, range.location == 0, range.length == 0 {
            delegate?.textCellDidEdit(cell: self, edit: .deleteAtBeginning)
            return false
        } else {
            return true
        }
    }
}
