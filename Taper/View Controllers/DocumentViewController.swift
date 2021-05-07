import UIKit

final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private var document: Document
    
    init(document: Document) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        title = document.title
        
        setupViews()
        configureCollectionView()
        configureGestures()
        configureNavigationBar()
        configureDataSource()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        
        let actions = BlockKind.allCases.map { kind in
            UIAction(title: kind.title, image: kind.image, handler: { [weak self] _ in
                self?.insertNewBlock(for: kind)
            })
        }
        
        let menu = UIMenu(title: "", children: actions)
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
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        cell.configure(with: block)
        cell.delegate = self
        return cell
    }

    private func todoBlockCell(for indexPath: IndexPath, block: TodoBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TodoBlockCellView.self, for: indexPath)
        cell.configure(with: block)
        cell.delegate = self
        cell.todoDelegate = self
        return cell
    }
    
    private func listItemBlockCell(for indexPath: IndexPath, block: ListItemBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
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
        if let indexPath = collectionView.indexPathForItem(at: location) {
            focusCell(at: indexPath)
        } else {
            // Tapped empty zone, add a new block
            autoAppendNewBlock()
        }
    }
    
    // MARK: - Editing
    
    private func apply(edit: TextEdit, to block: Block) {
        switch edit {
        case .insertNewline:
            insertBlock(block.content.next().asBlock(), after: block)
        case .deleteAtBeginning:
            deleteBlock(block)
        case .update(let content):
            updateBlockTextContent(content, block: block)
        }
    }
    
    // MARK: - Blocks
    
    private func index(of block: Block) -> Int? {
        document.blocks.firstIndex(of: block)
    }
    
    private func insertBlock(_ newBlock: Block, after existingBlock: Block) {
        if let index = index(of: existingBlock), index < document.blocks.endIndex {
            document.blocks.insert(newBlock, at: index + 1)
            updateDataSource()
            focusBlock(newBlock)
        } else {
            appendNewBlock(newBlock)
        }
    }
    
    private func insertNewBlock(for kind: BlockKind) {
        let block = makeBlock(for: kind)
        insertNewBlock(block)
    }
    
    private func makeBlock(for kind: BlockKind) -> Block {
        switch kind {
        case .heading:
            return TextBlock(style: .heading).asBlock()
        case .paragraph:
            return TextBlock(style: .paragraph).asBlock()
        case .todo:
            return TodoBlock().asBlock()
        case .bulletedListItem:
            return ListItemBlock(style: .bulleted).asBlock()
        case .numberedListItem:
            return ListItemBlock(style: .numbered).asBlock()
        }
    }
    
    /// Inserts will happen by default after active row, or at the end
    private func insertNewBlock(_ block: Block) {
        // TODO: find current active block
        appendNewBlock(block)
    }
    
    /// Appends a block at the end, ensuring it's the correct type based on the
    private func autoAppendNewBlock() {
        guard let block = document.blocks.last else {
            appendNewBlock(TextBlock().asBlock())
            return
        }
        
        if !block.content.isEmpty {
            appendNewBlock(block.content.empty().asBlock())
        } else {
            focusBlock(block)
        }
    }
    
    private func updateBlockTextContent(_ text: String, block: Block) {
        guard var content = block.content as? TextBlockContent else { return }

        content.text = text
        updateBlockContent(block, content: content, refresh: false)
    }
    
    private func updateBlockContent(_ block: Block, content: BlockContent, refresh: Bool = true) {
        guard let index = index(of: block) else { return }

        document.blocks[index] = content.asBlock()
        
        if refresh {
            updateDataSource()
        } else {
            // For some operations (like updating text), we invalidate the layout so it has the correct height
            // but don't need to create a whole new snapshot
            // TODO: find a better way than invalidating the whole layout when we know what row has changed
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func appendNewBlock(_ block: Block) {
        document.blocks.append(block)
        updateDataSource(animated: true)
        focusBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        guard let index = index(of: block) else {
            fatalError("Block not found in document! \(block)")
        }
        
        document.blocks.remove(at: index)
        updateDataSource()
        
        let previousIndex = index - 1
        if previousIndex >= 0, !document.blocks.isEmpty {
            focusBlock(document.blocks[previousIndex])
        }
    }
    
    // MARK: - Focus
    
    private func focusBlock(_ block: Block) {
        guard let index = index(of: block) else { return }
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
        BlockKind.allCases.forEach {
            collectionView.registerReusableCell($0.cellClass)
        }
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
        guard let block = block(for: cell), var content = block.content as? TodoBlock else {
            return
        }
        
        content.toggleCompletion()
        updateBlockContent(block, content: content, refresh: true)
    }
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit) {
        guard let block = block(for: cell) else { return }
        apply(edit: edit, to: block)
    }
}
