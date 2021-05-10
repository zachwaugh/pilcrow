import Foundation
import Combine

struct DocumentFile {
    let url: URL
    var name: String {
        url.deletingPathExtension().lastPathComponent
    }
}

final class DocumentStore {
    static let shared = DocumentStore()
    
    @Published private(set) var files: [DocumentFile] = []
    
    init() {
        refresh()
    }
    
    func refresh() {
        do {
            files = try listDocumentFiles()
        } catch {
            print("Error loading documents from filesystem: \(error)")
        }
    }
    
    func createNewDocument() -> Document {
        let name = findUniqueDocumentName()
        let document = Document(title: name)
        saveDocument(document)
        
        return document
    }
    
    func loadDocument(at url: URL) throws -> Document {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        let document = try decoder.decode(Document.self, from: data)
        
        return document
    }
    
    func saveDocument(_ document: Document) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(document)
            
            // TODO: we need unique filenames
            let url = url(for: document)
            try data.write(to: url)
        } catch {
            print("Error saving document: \(error)")
        }
        
        refresh()
    }
    
    func deleteDocument(_ document: Document) {
        deleteDocument(at: url(for: document))
    }
    
    func deleteDocument(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error deleting document at url: \(url)")
        }
        
        refresh()
    }
    
    // MARK: - Files
    
    private var documentsDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func url(for document: Document) -> URL {
        documentsDirectoryURL.appendingPathComponent("\(document.title).\(Document.fileExtension)")
    }
    
    private func listDocumentFiles() throws -> [DocumentFile] {
        let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: [], options: [])
        return urls.map { DocumentFile(url: $0) }
    }
    
    private func findUniqueDocumentName() -> String {
        let baseName = "Untitled"
        var filename = "\(baseName)"
        var attempt = 0
        
        var newURL = documentsDirectoryURL.appendingPathComponent("\(filename).\(Document.fileExtension)")
        
        while FileManager.default.fileExists(atPath: newURL.path) {
            attempt += 1
            filename = "\(baseName) - \(attempt)"
            newURL = documentsDirectoryURL.appendingPathComponent("\(filename).\(Document.fileExtension)")
        }
        
        return filename
    }
}
