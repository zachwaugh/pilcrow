import AppKit

final class TextView: NSTextView {
//    init() {
//        // TextKit 2
////        let textLayoutManager = NSTextLayoutManager()
////        let containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
////        let textContainer = NSTextContainer(size: containerSize)
////        textContainer.widthTracksTextView = true
////        textLayoutManager.textContainer = textContainer
////        let textContentStorage = NSTextContentStorage()
////        textContentStorage.addTextLayoutManager(textLayoutManager)
//
//        let textContainer = NSTextContainer(size: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
//        textContainer.widthTracksTextView = true
//        let layoutManager = NSLayoutManager()
//        layoutManager.addTextContainer(textContainer)
//        let textStorage = NSTextStorage()
//        textStorage.addLayoutManager(layoutManager)
//
//        super.init(frame: .zero, textContainer: textContainer)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override var intrinsicContentSize: NSSize {
        let tcHeight = ceil(textContainerHeight())
        let asHeight = ceil(attributedStringHeight())
        let height = asHeight
        print("[TextView] text container height: \(tcHeight), attributed string height: \(asHeight), bounds: \(bounds), frame: \(frame)")
        print("   => \(string)")

        return NSSize(width: NSView.noIntrinsicMetric, height: height)
    }
    
    private func textContainerHeight() -> CGFloat {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return 0
        }
        
        if string.isEmpty {
            print("[TextView] string is empty, using fixed height: 18")
            return 18
        }
        
        layoutManager.glyphRange(forBoundingRect: bounds, in: textContainer)
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size.height
    }
    
    private func attributedStringHeight() -> CGFloat {
        let content = string.isEmpty ? " " : string
        
        let attributedString = NSAttributedString(string: content, attributes: [
            .font: font!,
            .paragraphStyle: defaultParagraphStyle!
        ])
        
        let size = attributedString.boundingRect(with: NSSize(width: bounds.width, height: .greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin])
        
        return size.height
    }
    
    override var frame: NSRect {
        didSet {
            print("[TextView] frame did change: \(frame)")
            //invalidateIntrinsicContentSize()
        }
    }
    
    override var string: String {
        didSet {
            print("[TextView] string changed")
            //invalidateIntrinsicContentSize()
        }
    }
    
    override func didChangeText() {
        super.didChangeText()
        print("[TextView] didChangeText")
        //invalidateIntrinsicContentSize()
    }
    
    private func setup() {
        textStorage?.delegate = self
        layoutManager?.delegate = self
    }
}

extension TextView: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        print("[TextView] textStore: didProcessEditing: \(editedMask), editedRange: \(editedRange), delta: \(delta)")
    }
}

extension TextView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        print("[TextView] layoutManager: didCompleteLayout")
        invalidateIntrinsicContentSize()
    }
}
