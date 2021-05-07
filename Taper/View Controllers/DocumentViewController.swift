import UIKit

final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private var document: Document
    
    init(document: Document?) {
        self.document = document ?? Document()
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
//        configureGestures()
        configureNavigationBar()
        configureDataSource()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        
        let menu = UIMenu(title: "", children: [
            UIAction(title: "To Do", handler: { _ in
                self.appendNewBlock(TodoBlock().asBlock())
            }),
            UIAction(title: "Paragraph", handler: { _ in
                self.appendNewBlock(TextBlock().asBlock())
            }),
            UIAction(title: "Heading", handler: { _ in
                self.appendNewBlock(TextBlock(style: .heading).asBlock())
            }),
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
    }
    
    // MARK: - Data Source
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Block>!

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Block>(collectionView: collectionView, cellProvider: { _, indexPath, block in
            switch block {
            case .text(let block):
                return self.textBlockCell(for: indexPath, block: block)
            case .todo(let block):
                return self.todoBlockCell(for: indexPath, block: block)
            }
        })

        updateDataSource(animated: false)
    }
    
    private func updateDataSource(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Block>()
        snapshot.appendSections([.main])
        snapshot.appendItems(document.blocks)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Cells
    
    private func block(for cell: UICollectionViewCell) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return document.blocks[indexPath.row]
    }
    
    private func textBlockCell(for indexPath: IndexPath, block: TextBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "text", for: indexPath) as! TextBlockCellView
        cell.configure(with: block)
        cell.delegate = self
        return cell
    }

    private func todoBlockCell(for indexPath: IndexPath, block: TodoBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todo", for: indexPath) as! TodoBlockCellView
        cell.configure(with: block)
        cell.delegate = self
        return cell
    }
    
    // MARK: - Gestures
    
    private func configureGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        appendNewBlock(Block.todo(TodoBlock(completed: false, content: "")))
    }
    
    // MARK: - Actions
    
    private func insertBlock(_ block: Block, after indexPath: IndexPath) {
        if indexPath.row >= document.blocks.count - 1 {
            appendNewBlock(block)
        } else {
            document.blocks.insert(block, at: indexPath.row + 1)
            updateDataSource(animated: true)
            focusBlock(block)
        }
    }
    
    private func appendNewBlock(_ block: Block) {
        document.blocks.append(block)
        updateDataSource(animated: true)
        focusBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        guard let indexPath = dataSource.indexPath(for: block) else { return }
        document.blocks.remove(at: indexPath.row)
        updateDataSource(animated: true)
        
        // TODO: focus previous block
    }
    
    private func focusBlock(_ block: Block) {
        guard let indexPath = dataSource.indexPath(for: block) else { return }
        focusCell(at: indexPath)
    }
    
    private func focusCell(at indexPath: IndexPath) {
        guard let focusable = collectionView.cellForItem(at: indexPath) as? Focusable else { return }
        focusable.focus()
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
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.delegate = self
        return view
    }()
    
    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension DocumentViewController: UICollectionViewDelegate {
    
}

extension DocumentViewController: TodoCellDelegate {
    func todoCellDidToggleCheckBox(cell: TodoBlockCellView) {
        guard let indexPath = collectionView.indexPath(for: cell),
              case var .todo(todo) = document.blocks[indexPath.row]
        else {
            return
        }
        
        todo.toggle()
        document.blocks[indexPath.row] = .todo(todo)
        updateDataSource(animated: true)
    }
    
    func todoCellDidUpdateContent(cell: TodoBlockCellView, content: String) {
        guard let indexPath = collectionView.indexPath(for: cell),
              case var .todo(todo) = document.blocks[indexPath.row]
        else {
            return
        }

        todo.content = content
        document.blocks[indexPath.row] = .todo(todo)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidUpdateContent(cell: UICollectionViewCell, content: String) {
        guard let indexPath = collectionView.indexPath(for: cell),
              case var .text(text) = document.blocks[indexPath.row]
        else {
            return
        }
        
        text.content = content
        document.blocks[indexPath.row] = .text(text)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit) {
        guard let indexPath = collectionView.indexPath(for: cell), let block = block(for: cell) else { return }
        
        print("cell did edit: \(edit), block: \(block)")
        switch edit {
        case .enter:
            insertBlock(block.empty(), after: indexPath)
        case .delete:
            deleteBlock(block)
        }
    }
}
