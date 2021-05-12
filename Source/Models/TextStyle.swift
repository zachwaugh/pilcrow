import UIKit

enum TextStyle: String, Codable {
    case paragraph, heading, quote
    
    var font: UIFont {
        switch self {
        case .paragraph, .quote:
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        case .heading:
            return UIFont.systemFont(ofSize: 28, weight: .semibold)
        }
    }
}
