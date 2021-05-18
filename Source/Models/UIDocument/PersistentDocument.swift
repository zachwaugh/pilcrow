import UIKit

enum DocumentError: Error {
    case missingDocument
    case invalidArchive
}

final class PersistentDocument: UIDocument {
    var document: Document?
    
    convenience init() {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("Untitled.\(Document.fileExtension)")
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
