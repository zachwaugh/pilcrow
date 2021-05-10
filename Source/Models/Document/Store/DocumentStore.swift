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
        updateFiles()
    }
    
    func updateFiles() {
        do {
            files = try listDocumentFiles()
        } catch {
            print("Error loading documents from filesystem: \(error)")
        }
    }
    
    func createNewDocument(named name: String? = nil) -> Document {
        let name = findUniqueDocumentName(baseName: name ?? "Untitled")
        let document = Document(name: name)
        
        do {
            try saveDocument(document)
        } catch {
            print("Error creating new document: \(error)")
        }
        
        return document
    }
    
    func loadDocument(at url: URL) throws -> Document {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        let document = try decoder.decode(Document.self, from: data)
        
        return document
    }
    
    func renameDocument(at url: URL, to name: String) throws {
        // This is not very efficient to load and re-save the document just to rename
        // but right now the name is stored in the document itself
        // should probably just rely on the filesystem for that
        let oldDocument = try loadDocument(at: url)
        var document = oldDocument
        let filename = findUniqueDocumentName(baseName: name)
        document.name = filename
        try saveDocument(document)
        try deleteDocument(oldDocument)

        updateFiles()
    }
    
    func saveDocument(_ document: Document) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(document)
        
        // TODO: we need unique filenames
        let url = url(for: document)
        try data.write(to: url)

        updateFiles()
    }
    
    func deleteDocument(_ document: Document) throws {
        try deleteDocument(at: url(for: document))
    }
    
    func deleteDocument(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
        updateFiles()
    }
    
    // MARK: - Files
    
    private var documentsDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func url(for document: Document) -> URL {
        url(for: document.name)
    }
    
    private func url(for filename: String) -> URL {
        documentsDirectoryURL.appendingPathComponent("\(filename).\(Document.fileExtension)")
    }
    
    private func listDocumentFiles() throws -> [DocumentFile] {
        let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: [], options: [])
        return urls.map { DocumentFile(url: $0) }
    }
    
    private func findUniqueDocumentName(baseName: String) -> String {
        var filename = "\(baseName)"
        var attempt = 0
        var newURL = url(for: filename)
        
        while FileManager.default.fileExists(atPath: newURL.path) {
            attempt += 1
            filename = "\(baseName) - \(attempt)"
            newURL = url(for: filename)
        }
        
        return filename
    }
}

extension DocumentStore {
    func saveTestDocumentIfNeeded() {
        #if DEBUG
        guard !files.map(\.name).contains(Document.test.name) else { return }
        try? saveDocument(.test)
        #endif
    }
}
