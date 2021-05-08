import Foundation

struct Document: Codable, Equatable {
    var title: String = "Untitled"
    var blocks: [Block] = []
}
