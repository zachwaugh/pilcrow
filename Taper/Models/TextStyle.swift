import UIKit

enum TextStyle: String, Codable {
    case paragraph, heading
    
    var font: UIFont {
        switch self {
        case .paragraph:
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        case .heading:
            return UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
    }
}
