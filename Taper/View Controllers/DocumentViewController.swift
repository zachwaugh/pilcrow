import UIKit

final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private var document: Document
    
    init(document: Document) {
        self.document = document
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
        configureNavigationBar()
        configureDataSource()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        
        let menu = UIMenu(title: "", children: [
            UIAction(title: "To Do", handler: { _ in
                self.appendNewBlock(TodoBlock().asBlock())
            }),
            UIAction(title: "Bullet List Item", handler: { _ in
                self.appendNewBlock(ListItemBlock().asBlock())
            }),
            UIAction(title: "Numbered List Item", handler: { _ in
                self.appendNewBlock(ListItemBlock(style: .number(1)).asBlock())
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
        dataSource = UICollectionViewDiffableDataSource<Section, Block>(collectionView: collectionView) { [weak self] _, indexPath, block in
            self?.cell(for: indexPath, block: block)
        }

        updateDataSource()
    }
    
    /// Update data source snapshot from document
    private func updateDataSource(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Block>()
        snapshot.appendSections([.main])
        snapshot.appendItems(document.blocks)
        
        print("Updating data source with snapshot: \(snapshot.numberOfItems), animated? \(animated)")
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Cells
    
    private func block(for cell: UICollectionViewCell) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return document.blocks[indexPath.row]
    }
    
    private func cell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        switch block {
        case .text(let block):
            return self.textBlockCell(for: indexPath, block: block)
        case .todo(let block):
            return self.todoBlockCell(for: indexPath, block: block)
        case .listItem(let block):
            return self.listItemBlockCell(for: indexPath, block: block)
        }
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
        cell.todoDelegate = self
        return cell
    }
    
    private func listItemBlockCell(for indexPath: IndexPath, block: ListItemBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listItem", for: indexPath) as! ListItemBlockCellView
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
        let location = gesture.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        
        if indexPath == nil {
            autoAppendNewBlock()
        }
    }
    
    // MARK: - Actions
    
    private func insertBlock(_ block: Block, after indexPath: IndexPath) {
        if indexPath.row >= document.blocks.count - 1 {
            appendNewBlock(block)
        } else {
            document.blocks.insert(block, at: indexPath.row + 1)
            updateDataSource()
            focusBlock(block)
        }
    }
    
    /// Appends a block at the end, ensuring it's the correct type based on the
    private func autoAppendNewBlock() {
        guard let block = document.blocks.last else {
            appendNewBlock(TextBlock().asBlock())
            return
        }
        
        if !block.blockable.isEmpty {
            appendNewBlock(block.empty())
        } else {
            focusBlock(block)
        }
    }
    
    private func updateBlockTextContent(_ content: String, block: Block, at indexPath: IndexPath) {
        guard var textBlock = block.blockable as? TextBlockable else { return }

        // Update the underlying document, but the data source doesn't need to change
        // just invalidate the layout so it has the correct height
        // TODO: probably a better way than invalidating the whole layout when we know what row has changed
        textBlock.content = content
        document.blocks[indexPath.row] = textBlock.asBlock()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func appendNewBlock(_ block: Block) {
        document.blocks.append(block)
        updateDataSource(animated: true)
        focusBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        guard let index = document.blocks.firstIndex(of: block) else {
            print("Error: block not found in document! \(block)")
            return
        }
        
        document.blocks.remove(at: index)
        updateDataSource(animated: false)
        
        let previousIndex = index - 1
        if previousIndex >= 0, !document.blocks.isEmpty {
            focusBlock(document.blocks[previousIndex])
        }
    }
    
    // MARK: - Focus
    
    private func focusBlock(_ block: Block) {
        guard let index = document.blocks.firstIndex(of: block) else { return }
        focusCell(at: index)
    }
    
    private func focusCell(at index: Int) {
        focusCell(at: IndexPath(item: index, section: 0))
    }
    
    private func focusCell(at indexPath: IndexPath) {
        guard let focusableView = collectionView.cellForItem(at: indexPath) as? FocusableView else { return }
        focusableView.focus()
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
        collectionView.register(ListItemBlockCellView.self, forCellWithReuseIdentifier: "listItem")
    }
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
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
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit) {
        guard let indexPath = collectionView.indexPath(for: cell), let block = block(for: cell) else { return }
        
        //print("cell did edit: \(edit), block: \(block)")
        switch edit {
        case .insertNewline:
            insertBlock(block.next(), after: indexPath)
        case .deleteAtBeginning:
            deleteBlock(block)
        case .update(let content):
            updateBlockTextContent(content, block: block, at: indexPath)
        }
    }
}
