import UIKit

enum Metrics {
    static let sectionTopPadding: CGFloat = 16
    
    /// Spacing in-between adjacent blocks
    static let blockSpacing: CGFloat = 12
    
    /// Leading/trailing padding of content blocks
    static let blockContentHorizontalPadding: CGFloat = 16
    
    static let estimatedBlockHeight: CGFloat = 40
    static let listItemLabelContentSpacing: CGFloat = 4
    
    // Todos
    static let checkboxSize = CGSize(width: 30, height: 30)
    static let checkboxTextContentSpacing: CGFloat = 8
    
    /// Offset so text view visually lines up with checkbox
    static let checkboxTextContentVerticalOffset: CGFloat = 4
    
    // Block quoates
    static let quoteBorderWidth: CGFloat = 3
    static let quoteBorderSpacing: CGFloat = 12
    static let quoteContentVerticalPadding: CGFloat = 4
    
    // Divider
    static let dividerVerticalSpacing: CGFloat = 16
    static let dividerMaxWidth: CGFloat = 200
    
    // Toolbar
    static let toolbarHeight: CGFloat = 44
    static let toolbarButtonSize = CGSize(width: 40, height: 40)
}
