import Foundation
import Pilcrow
import UIKit

struct ColorBlockViewModel {
    let block: Block
    
    var backgroundColor: UIColor? {
        switch block["color"] {
        case "red":
            return .systemRed
        case "blue":
            return .systemBlue
        default:
            return nil
        }
    }
}
