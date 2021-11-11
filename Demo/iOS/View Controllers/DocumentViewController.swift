import UIKit
import Combine
import Pilcrow

// TODO: this is a beast, will refactor
final class DocumentViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private var file: DocumentFile
    private var editor: DocumentEditor!
    private var document: Document { editor.document }
    private var subscriptions: Set<AnyCancellable> = []
    
    init(file: DocumentFile) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setupViews()
        configureGestures()
        configureNavigationBar()
        
        loadDocument()
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeDocument))
        
        #if DEBUG
        let testDocument = UIAction(title: "Insert Test Blocks", image: UIImage(systemName: "rectangle.stack.badge.plus")) { [weak self] _ in
            self?.editor.appendBlocks(Document.test.blocks)
            self?.updateDataSource()
        }
        let menu = UIMenu(title: "", children: [testDocument])
        #else
        let menu = UIMenu(title: "", children: [])
        #endif
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
    }
    
    private func observeEditor() {
        editor.changes
            .sink { [weak self] editResult in
                self?.applyEditResult(editResult)
                self?.documentEdited()
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Document
    
    private func loadDocument() {
        file.open { [weak self] success in
            print("[Demo] File opened, success? \(success)")

            if success {
                self?.documentOpened()
            } else {
                // TODO: handle error
                print("[Demo] *** error opening document!")
            }
        }
    }
    
    private func documentOpened() {
        guard let document = file.document else { return }
        
        title = file.name
        print("[Demo] documentOpened(), creating editor")

        editor = DocumentEditor(document: document)
        observeEditor()
        setupDataSource()
    }
    
    private func documentEdited() {
        file.document = document
        file.updateChangeCount(.done)
    }
    
    @objc private func closeDocument() {
        file.close { [weak self] success in
            print("[Demo] File closed, success? \(success)")
            
            if success {
                self?.dismiss(animated: true)
            } else {
                // TODO: handle save error
            }
        }
    }
    
    // MARK: - Data Source
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!

    private func setupDataSource() {
        let textCell = UICollectionView.CellRegistration<TextBlockCellView, Block> { cell, indexPath, block in
            let viewModel = TextBlockViewModel(block: block, style: block.kind == .heading ? .heading : .paragraph)
            cell.configure(with: viewModel)
            cell.delegate = self
            cell.toolbarController.delegate = self
        }
        
        let quoteCell = UICollectionView.CellRegistration<QuoteBlockCellView, Block> { cell, indexPath, block in
            let viewModel = QuoteBlockViewModel(block: block)
            cell.configure(with: viewModel)
            cell.delegate = self
            cell.delegate = self
            cell.toolbarController.delegate = self
        }

        let todoCell = UICollectionView.CellRegistration<TodoBlockCellView, Block> { cell, indexPath, block in
            let viewModel = TodoBlockViewModel(block: block)
            cell.configure(with: viewModel)
            cell.todoDelegate = self
            cell.delegate = self
            cell.toolbarController.delegate = self
        }
        
        let bulletedListItemCell = UICollectionView.CellRegistration<ListItemBlockCellView, Block> { cell, indexPath, block in
            let viewModel = ListItemBlockViewModel(block: block)
            cell.configure(with: viewModel)
            cell.delegate = self
            cell.toolbarController.delegate = self
        }
        
//        let numberedListItemCell = UICollectionView.CellRegistration<ListItemBlockCellView, Block> { cell, indexPath, block in
//            let viewModel = ListItemBlockViewModel(block: block, listItemLabelString: "1.")
//            cell.configure(with: viewModel)
//            cell.delegate = self
//            cell.toolbarController.delegate = self
//        }
        
        let dividerCell = UICollectionView.CellRegistration<DividerBlockCellView, Block> { cell, indexPath, block in
            let viewModel = DividerBlockViewModel(block: block)
            cell.configure(with: viewModel)
        }
        
        let colorCell = UICollectionView.CellRegistration<ColorBlockCellView, Block> { cell, indexPath, block in
            let viewModel = ColorBlockViewModel(block: block)
            cell.configure(with: viewModel)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { [unowned self] collectionView, indexPath, id in
            guard let block = self.document.block(with: id) else {
                fatalError("Couldn't find block with id: \(id)")
            }
            
            switch block.kind {
            case .quote:
                return collectionView.dequeueConfiguredReusableCell(using: quoteCell, for: indexPath, item: block)
            case .todo:
                return collectionView.dequeueConfiguredReusableCell(using: todoCell, for: indexPath, item: block)
            case .listItem:
                return collectionView.dequeueConfiguredReusableCell(using: bulletedListItemCell, for: indexPath, item: block)
            case .divider:
                return collectionView.dequeueConfiguredReusableCell(using: dividerCell, for: indexPath, item: block)
            case .heading, .paragraph:
                return collectionView.dequeueConfiguredReusableCell(using: textCell, for: indexPath, item: block)
            case .color:
                return collectionView.dequeueConfiguredReusableCell(using: colorCell, for: indexPath, item: block)
            default:
                print("No cell for block kind: \(block.kind), falling back to text")
                return collectionView.dequeueConfiguredReusableCell(using: textCell, for: indexPath, item: block)
            }
        }

        updateDataSource()
    }
    
    private func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, String> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(document.blocks.map(\.id))
        return snapshot
    }
    
    /// Update data source snapshot from document
    private func updateDataSource(animated: Bool = false) {
        dataSource.apply(makeSnapshot(), animatingDifferences: animated)
    }
    
    private func reconfigureBlocks(_ blocks: [Block], animated: Bool = false) {
        var snapshot = makeSnapshot()
        snapshot.reconfigureItems(blocks.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func reloadBlocks(_ blocks: [Block], animated: Bool = false) {
        var snapshot = makeSnapshot()
        snapshot.reloadItems(blocks.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Editing
    
    private func applyEditResult(_ result: EditResult?) {
        guard let result = result else { return }
        
        switch result {
        case .inserted(let id):
            updateDataSource()
            let block = document.block(with: id)!
            focusBlock(block)
        case .updatedContent(let id):
            let block = document.block(with: id)!
            reconfigureBlocks([block])
        case .updatedKind(let id):
            let block = document.block(with: id)!
            reloadBlocks([block])
            focusBlock(block)
        case .deleted(let id, let index):
            updateDataSource()
            focusCell(before: index)
        case .moved:
            updateDataSource()
        }
    }
        
    // MARK: - Block Edits
    
    private func updateBlock(at indexPath: IndexPath, to kind: Block.Kind) {
        guard let block = document.block(at: indexPath.row) else { return }
        updateBlock(block, to: kind)
    }
    
    private func updateBlock(_ block: Block, to kind: Block.Kind) {
        guard kind != block.kind, block.kind.isDecorative == kind.isDecorative else { return }
        editor.updateBlockKind(for: block, to: kind)
    }
    
    private func insertOrModifyEditingBlock(for kind: Block.Kind) {
        if let block = editingBlock {
            guard kind != block.kind else { return }
            
            switch kind {
            case .divider:
                let newBlock = Block(kind: .divider)
                editor.insertBlock(newBlock, after: block)
            case .color:
                let newBlock = Block(kind: .color, properties: ["color": "red"])
                editor.insertBlock(newBlock, after: block)
            default:
                editor.updateBlockKind(for: block, to: kind)
            }
        } else {
            editor.appendBlock(Block(kind: kind))
        }
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
    
    private func deleteBlock(at indexPath: IndexPath) {
        let block = document.blocks[indexPath.row]
        deleteBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        editor.deleteBlock(block)
    }
    
    // MARK: - Cells
    
    private func block(for cell: UICollectionViewCell) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return document.block(at: indexPath.row)
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
            editor.appendNewBlock()
        }
    }
    
    // MARK: - Focus
    
    private func focusBlock(_ block: Block) {
        guard let index = document.index(of: block) else { return }
        focusCell(at: index)
    }
    
    private func focusCell(at index: Int) {
        focusCell(at: IndexPath(item: index, section: 0))
    }
    
    private func focusCell(before block: Block) {
        guard let index = document.index(of: block) else { return }

        let previousIndex = index - 1
        if previousIndex >= 0, !document.blocks.isEmpty {
            focusCell(at: previousIndex)
        }
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


extension DocumentViewController: TodoCellDelegate {
    func todoCellDidToggleCheckBox(cell: TodoBlockCellView) {
        guard let block = block(for: cell) else { return }
        editor.toggleCompletion(for: block)
    }
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidEdit(cell: UICollectionViewCell, edit: TextEdit) {
        guard let block = block(for: cell) else { return }
        editor.apply(edit: edit, to: block)
    }
}

extension DocumentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [unowned self] _ in
            self.deleteBlock(at: indexPath)
        }
        
        let changeActions = Block.Kind.all.map { kind in
            UIAction(title: kind.title, image: kind.image) { [unowned self] _ in
                self.updateBlock(at: indexPath, to: kind)
            }
        }
        
        let changeMenu = UIMenu(title: "Change to…", children: changeActions)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [
                deleteAction,
                changeMenu
            ])
        }
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
              let block = document.block(at: sourceIndexPath.row),
              let destinationIndexPath = coordinator.destinationIndexPath
        else {
            return
        }
        
        editor.moveBlock(block, to: destinationIndexPath.row)        
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}

extension DocumentViewController: ToolbarDelegate {
    func toolbarDidTapButton(action: ToolbarAction) {
        switch action {
        case .selectBlock(let kind):
            insertOrModifyEditingBlock(for: kind)
        case .dismissKeyboard:
            view.endEditing(true)
        }
    }
}
