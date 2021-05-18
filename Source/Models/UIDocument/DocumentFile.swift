import UIKit

enum DocumentError: Error {
    case missingDocument
    case invalidArchive
}

final class DocumentFile: UIDocument {
    static let fileExtension = "pilcrow"

    var document: Document?
    var name: String {
        let fileAttributes = try? fileURL.resourceValues(forKeys: [URLResourceKey.localizedNameKey])
        return fileAttributes?.localizedName ?? fileURL.deletingPathExtension().lastPathComponent
    }
    
    convenience init() {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("Untitled.\(Self.fileExtension)")
        self.init(fileURL: url)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let doc = document ?? Document()
        let encoder = JSONEncoder()
        let data = try encoder.encode(doc)
        return data
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else {
            throw DocumentError.invalidArchive
        }
        
        let decoder = JSONDecoder()
        document = try decoder.decode(Document.self, from: data)
    }
}
