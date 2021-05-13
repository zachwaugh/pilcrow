import Foundation

struct DividerContent: Hashable, Identifiable, Codable, BlockContent {
    let id: String
    
    init() {
        self.id = UUID().uuidString
    }
        
    func asBlock() -> Block {
        .divider(self)
    }
    
    func empty() -> DividerContent {
        DividerContent()
    }
}
