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
    }
    
    private func observeStore() {
        files = store.files
        
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
        let document = Document()
        store.saveDocument(document)
        open(document: document)
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
            
            self?.store.deleteDocument(at: file.url)
            handler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
