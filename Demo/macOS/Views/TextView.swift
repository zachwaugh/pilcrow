import AppKit

final class TextView: NSTextView {
    override var intrinsicContentSize: NSSize {
        let height = ceil(textContainerHeight())
        return NSSize(width: NSView.noIntrinsicMetric, height: height)
    }
    
    private func textContainerHeight() -> CGFloat {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return 0
        }
        
        layoutManager.ensureLayout(for: textContainer)
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size.height
    }
}
