import UIKit

enum DocumentError: Error {
    case missingDocument
    case invalidArchive
}

final class PersistentDocument: UIDocument {
    var document: Document?
    
    override func contents(forType typeName: String) throws -> Any {
        print("contents(forType: \(typeName)")
        guard let document = document else {
            throw DocumentError.missingDocument
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(document)
        return data
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        print("load(fromContents: ofType: \(typeName)")
        guard let data = contents as? Data else {
            throw DocumentError.invalidArchive
        }
        
        let decoder = JSONDecoder()
        document = try decoder.decode(Document.self, from: data)
    }
}
