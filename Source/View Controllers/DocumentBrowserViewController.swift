import UIKit

final class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let document = PersistentDocument()
        
        document.save(to: document.fileURL, for: .forCreating) { success in
            guard success else {
                print("*** Error: creating new document")
                importHandler(nil, .none)
                return
            }
            
            document.close { success in
                guard success else {
                    print("*** Error: closing newly created document")
                    importHandler(nil, .none)
                    return
                }
                
                importHandler(document.fileURL, .move)
            }
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        editDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        editDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // TODO: present error
        print("failedToImportDocumentAt: \(documentURL), error: \(String(describing: error))")
    }
    
    // MARK: Document Editing
    
    func editDocument(at documentURL: URL) {
        let editor = DocumentViewController(persistentDocument: PersistentDocument(fileURL: documentURL))

        #if targetEnvironment(macCatalyst)
            present(editor, animated: true)
        #else
            let navController = UINavigationController(rootViewController: editor)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        #endif
    }
}
