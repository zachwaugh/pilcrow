import UIKit
import Pilcrow

enum DocumentError: Error {
    case missingDocument
    case invalidArchive
}

final class DocumentFile: UIDocument {
    static let fileExtension = "pilcrow"

    var document: Document?
    var name: String { localizedName }
    
    convenience init() {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("Untitled.\(Self.fileExtension)")
        self.init(fileURL: url)
    }
    
    override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
        print("[DocumentFile] save to \(url)")
        super.save(to: url, for: saveOperation, completionHandler: completionHandler)
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
