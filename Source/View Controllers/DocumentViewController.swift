import UIKit

final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private let editor: DocumentEditor
    private var document: Document { editor.document }
    
    init(document: Document) {
        self.editor = DocumentEditor(document: document)
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        title = document.name
        
        setupViews()
        configureCollectionView()
        configureGestures()
        configureNavigationBar()
        configureDataSource()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        
        let addActions = BlockKind.allCases.map { kind in
            UIAction(title: kind.title, image: kind.image, handler: { [weak self] _ in
                self?.makeAndInsertNewBlock(for: kind)
            })
        }
        
        let menu = UIMenu(title: "", children: addActions)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
    }
    
    // MARK: - Document
    
    private func save() {
        // TODO: throttle/debounce saves
        do {
            try DocumentStore.shared.saveDocument(document)
        } catch {
            print("Error saving document! \(error)")
        }
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
    
    private func applyEditResult(_ result: EditResult?) {
        guard let result = result else { return }
        
        switch result {
        case .inserted(let index):
            updateDataSource()
            focusCell(at: index)
        case .invalidated:
            // For some operations (like updating text), we invalidate the layout so it has the correct height
            // but don't need to create a whole new snapshot
            // TODO: find a better way than invalidating the whole layout when we know what row has changed
            collectionView.collectionViewLayout.invalidateLayout()
        case .updated:
            updateDataSource()
        case .deleted(let index):
            updateDataSource()
            focusCell(before: index)
        }
        
        save()
    }
    
    // MARK: - Blocks
    
    private func makeAndInsertNewBlock(for kind: BlockKind) {
        let newBlock = makeBlock(for: kind)
        let result: EditResult
        
        if let activeBlock = findActiveBlock() {
            result = editor.insertBlock(newBlock, after: activeBlock)
        } else {
            result = editor.appendBlock(newBlock)
        }
        
        applyEditResult(result)
    }
    
    /// Return the block that has focus, or nil if none
    private func findActiveBlock() -> Block? {
        // TODO: find actual block, for now we'll return last
        document.blocks.last
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

    // MARK: - Cells
    
    private func block(for cell: UICollectionViewCell) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return document.blocks[indexPath.row]
    }
    
    private func cell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        switch block {
        case .text(let content):
            return self.textBlockCell(for: indexPath, content: content)
        case .todo(let content):
            return self.todoBlockCell(for: indexPath, content: content)
        case .listItem(let content):
            return self.listItemBlockCell(for: indexPath, content: content)
        }
    }
    
    private func textBlockCell(for indexPath: IndexPath, content: TextBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        let viewModel = TextBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }

    private func todoBlockCell(for indexPath: IndexPath, content: TodoBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TodoBlockCellView.self, for: indexPath)
        let viewModel = TodoBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        cell.todoDelegate = self
        return cell
    }
    
    private func listItemBlockCell(for indexPath: IndexPath, content: ListItemBlock) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
        let viewModel = ListItemBlockViewModel(content: content)
        cell.configure(with: viewModel)
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
            applyEditResult(editor.appendNewBlock())
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
    
    private func focusCell(before index: Int) {
        let previousIndex = index - 1
        if previousIndex >= 0, !document.blocks.isEmpty {
            focusCell(at: previousIndex)
        }
    }
    
    private func focusCell(after index: Int) {
        let nextIndex = index + 1
        if nextIndex < document.blocks.count - 1 {
            focusCell(at: nextIndex)
        }
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
        guard let block = block(for: cell) else { return }
        
        let result = editor.toggleCompletion(for: block)
        applyEditResult(result)
    }
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit) {
        guard let block = block(for: cell) else { return }
        
        let result = editor.apply(edit: edit, to: block)
        applyEditResult(result)
    }
}
