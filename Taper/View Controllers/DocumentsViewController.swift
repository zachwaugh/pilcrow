import UIKit

final class DocumentsViewController: UITableViewController {
    private var documents: [Document] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(documents: [Document]) {
        self.documents = documents
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
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newDocument(_:)))
    }
    
    // MARK: Actions
    
    @objc private func newDocument(_ sender: Any) {
        let document = Document()
        documents.append(document)
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
        documents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "document", for: indexPath)
        let document = documents[indexPath.row]
        cell.textLabel?.text = document.title
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(document: documents[indexPath.row])
    }
}
