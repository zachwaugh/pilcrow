import Foundation

protocol FocusableView {
    func focus()
    var hasFocus: Bool { get }
}
