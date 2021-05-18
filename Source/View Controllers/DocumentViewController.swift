import UIKit

final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private var persistentDocument: PersistentDocument
    private var editor: DocumentEditor!
    private var document: Document { editor.document }
    
    init(persistentDocument: PersistentDocument) {
        self.persistentDocument = persistentDocument
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        loadFile()
        setupViews()
        configureCollectionView()
        configureGestures()
        configureNavigationBar()
    }
    
    private func loadFile() {
        persistentDocument.open { [weak self] success in
            if success {
                self?.documentOpenedSuccessfully()
            } else {
                // TODO: handle error
            }
        }
    }
    
    private func documentOpenedSuccessfully() {
        guard let document = persistentDocument.document else { return }
        
        editor = DocumentEditor(document: document)
        title = persistentDocument.name
        configureDataSource()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeDocument))
        
        let addActions = Block.Kind.allCases.map { kind in
            UIAction(title: kind.title, image: kind.image, handler: { [weak self] _ in
                self?.makeAndInsertNewBlock(for: kind)
            })
        }
        
        let menu = UIMenu(title: "", children: addActions)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
    }
    
    // MARK: - Document
    
    private func documentEdited() {
        persistentDocument.document = document
        persistentDocument.updateChangeCount(.done)
    }
    
    @objc private func closeDocument() {
        persistentDocument.close { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            } else {
                // TODO: handle save error
            }
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
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Editing
    
    private func applyEdit(_ edit: TextEdit, to block: Block) {
        let result = editor.apply(edit: edit, to: block)
        applyEditResult(result)
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
        
        documentEdited()
    }
        
    // MARK: - Blocks
    
    private func makeAndInsertNewBlock(for kind: Block.Kind) {
        let newBlock = makeBlock(for: kind)
        let result: EditResult
        
        if let block = editingBlock {
            result = editor.insertBlock(newBlock, after: block)
        } else {
            result = editor.appendBlock(newBlock)
        }
        
        applyEditResult(result)
    }
    
    /// Find the cell currently being edited if any
    private var editingCell: UICollectionViewCell? {
        for cell in collectionView.visibleCells {
            guard let focusableView = cell as? FocusableView else { continue }
            
            if focusableView.hasFocus {
                return cell
            }
        }
        
        return nil
    }
    
    /// Return the block being edited, or nil if none
    private var editingBlock: Block? {
        let editingBlock = editingCell.map { block(for: $0) }
        return editingBlock ?? document.blocks.last
    }
    
    private func makeBlock(for kind: Block.Kind) -> Block {
        switch kind {
        case .heading:
            return HeadingContent().asBlock()
        case .paragraph:
            return ParagraphContent().asBlock()
        case .quote:
            return QuoteContent().asBlock()
        case .todo:
            return TodoContent().asBlock()
        case .bulletedListItem:
            return BulletedListItemContent().asBlock()
        case .numberedListItem:
            return NumberedListItemContent().asBlock()
        case .divider:
            return DividerContent().asBlock()
        }
    }
    
    private func deleteBlock(at indexPath: IndexPath) {
       let block = document.blocks[indexPath.row]
        deleteBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        editor.deleteBlock(block)
        updateDataSource(animated: true)
        documentEdited()
    }
    
    // MARK: - Cells
    
    private func block(for cell: UICollectionViewCell) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return block(at: indexPath)
    }
    
    private func block(at indexPath: IndexPath) -> Block? {
        guard indexPath.row >= 0, indexPath.row < document.blocks.count else { return nil }
        return document.blocks[indexPath.row]
    }
    
    private func cell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        switch block {
        case .heading(let content):
            return self.headingBlockCell(for: indexPath, content: content)
        case .paragraph(let content):
            return self.paragraphBlockCell(for: indexPath, content: content)
        case .quote(let content):
            return self.quoteBlockCell(for: indexPath, content: content)
        case .todo(let content):
            return self.todoBlockCell(for: indexPath, content: content)
        case .bulletedListItem(let content):
            return self.bulletedListItemBlockCell(for: indexPath, content: content)
        case .numberedListItem(let content):
            return self.numberedListItemBlockCell(for: indexPath, content: content)
        case .divider(let content):
            return self.dividerBlockCell(for: indexPath, content: content)
        }
    }
    
    private func paragraphBlockCell(for indexPath: IndexPath, content: ParagraphContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        let viewModel = TextBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    private func headingBlockCell(for indexPath: IndexPath, content: HeadingContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        let viewModel = TextBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    private func quoteBlockCell(for indexPath: IndexPath, content: QuoteContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(QuoteBlockCellView.self, for: indexPath)
        let viewModel = QuoteBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }

    private func todoBlockCell(for indexPath: IndexPath, content: TodoContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TodoBlockCellView.self, for: indexPath)
        let viewModel = TodoBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        cell.todoDelegate = self
        return cell
    }
    
    private func bulletedListItemBlockCell(for indexPath: IndexPath, content: BulletedListItemContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
        let viewModel = ListItemBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    private func numberedListItemBlockCell(for indexPath: IndexPath, content: NumberedListItemContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
        let viewModel = ListItemBlockViewModel(content: content)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    private func dividerBlockCell(for indexPath: IndexPath, content: DividerContent) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(DividerBlockCellView.self, for: indexPath)
        let viewModel = DividerBlockViewModel(content: content)
        cell.configure(with: viewModel)
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
        Block.Kind.allCases.forEach {
            collectionView.registerReusableCell($0.cellClass)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.delegate = self
        view.dragDelegate = self
        view.dropDelegate = self
        view.dragInteractionEnabled = true
        
        return view
    }()
    
    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(Metrics.estimatedBlockHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(Metrics.blockSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Metrics.sectionTopPadding, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension DocumentViewController: UICollectionViewDelegate {}

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
        
        applyEdit(edit, to: block)
    }
}

extension DocumentViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Use empty NSItemProvider since we'll rely on the sourceIndexPath when dropping to access block
        [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        true
    }
}

extension DocumentViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let block = block(at: sourceIndexPath),
              let destinationIndexPath = coordinator.destinationIndexPath
        else {
            return
        }
        
        editor.moveBlock(block, to: destinationIndexPath.row)
        updateDataSource()
        documentEdited()
        
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}
