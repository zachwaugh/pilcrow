import UIKit

protocol ReusableCell: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell: ReusableCell {}

extension UICollectionView {
    func registerReusableCell<T: ReusableCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: ReusableCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
    }
}
