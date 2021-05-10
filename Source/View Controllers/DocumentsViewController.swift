import UIKit
import Combine

final class DocumentsViewController: UITableViewController {
    private let store: DocumentStore
    private var subscriptions: Set<AnyCancellable> = []
    
    private var files: [DocumentFile] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(store: DocumentStore) {
        self.store = store
        super.init(style: .plain)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        title = "Documents"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "document")
        configureNavigationBar()
        observeStore()
        
        #if DEBUG
        store.saveTestDocumentIfNeeded()
        #endif
    }
    
    private func observeStore() {
        store.$files
            .sink { [weak self] files in
                self?.files = files
            }
            .store(in: &subscriptions)
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newDocument(_:)))
    }
    
    // MARK: Actions
    
    @objc private func newDocument(_ sender: Any) {
        promptForDocumentName(currentName: "Untitled") { [weak self] name in
            self?.createDocument(with: name)
        }
    }
    
    private func createDocument(with name: String) {
        let document = store.createNewDocument(named: name)
        open(document: document)
    }
    
    private func promptToRenameDocument(file: DocumentFile) {
        promptForDocumentName(currentName: file.name) { [weak self] updatedName in
            self?.renameDocument(file: file, name: updatedName)
        }
    }
    
    private func renameDocument(file: DocumentFile, name: String) {
        do {
            try store.renameDocument(at: file.url, to: name)
        } catch {
            print("Error renaming document: \(error)")
        }
    }
    
    private func promptForDocumentName(currentName: String, handler: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Document Name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = currentName
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            handler(name)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // MARK: Navigation
    
    private func open(document: Document) {
        let documentViewController = DocumentViewController(document: document)
        navigationController?.pushViewController(documentViewController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "document", for: indexPath)
        cell.textLabel?.text = files[indexPath.row].name
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = files[indexPath.row]
        
        do {
            let document = try store.loadDocument(at: file.url)
            open(document: document)
        } catch {
            print("Error loading document at url: \(file.url), error: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, handler in
            guard let file = self?.files[indexPath.row] else {
                handler(false)
                return
            }
            
            do {
                try self?.store.deleteDocument(at: file.url)
                handler(true)
            } catch {
                print("Error deleting document: \(error)")
                handler(false)
            }
        }
        
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, handler in
            guard let file = self?.files[indexPath.row] else {
                handler(false)
                return
            }
            
            self?.promptToRenameDocument(file: file)
            handler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
    }
}
