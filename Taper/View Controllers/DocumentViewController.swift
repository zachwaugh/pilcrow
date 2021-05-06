import UIKit

final class DocumentViewController: UIViewController {
    private var document: Document {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(document: Document?) {
        self.document = document ?? Document(title: "Untitled", blocks: [])
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = document.title
        setupViews()
        configureCollectionView()
        configureGestures()
    }
    
    // MARK: - Gestures
    
    private func configureGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        appendNewBlock()
    }
    
    // MARK: - Actions
    
    private func appendNewBlock() {
        document.blocks.append(TodoBlock(completed: false, content: ""))
    }

    // MARK: - Views
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(TextBlockCellView.self, forCellWithReuseIdentifier: "text")
        collectionView.register(TodoBlockCellView.self, forCellWithReuseIdentifier: "todo")
    }
    
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
}

extension DocumentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let block = document.blocks[indexPath.row]
        
        switch block.kind {
        case .text:
            return textBlockCell(for: indexPath, block: block as! TextBlock)
        case .todo:
            return todoBlockCell(for: indexPath, block: block as! TodoBlock)
        }
    }
    
    private func textBlockCell(for indexPath: IndexPath, block: TextBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "text", for: indexPath) as! TextBlockCellView
        cell.configure(with: block)
        return cell
    }
    
    private func todoBlockCell(for indexPath: IndexPath, block: TodoBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todo", for: indexPath) as! TodoBlockCellView
        cell.configure(with: block)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        document.blocks.count
    }
}

extension DocumentViewController: UICollectionViewDelegate {
    
}
