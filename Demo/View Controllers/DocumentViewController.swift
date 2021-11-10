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
        configureCollectionView()
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
        editor.$edits
            .dropFirst()
            .sink { [weak self] _ in
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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Block>!

    private func setupDataSource() {
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
        case .updated(let index):
            updateDataSource()
            focusCell(at: index)
        case .deleted(let index):
            updateDataSource()
            focusCell(before: index)
        }
    }
        
    // MARK: - Blocks
    
    private func insertOrModifyBlock(for kind: Block.Kind) {
        let result: EditResult?
        
        if let block = editingBlock {
            result = editor.updateBlockKind(for: block, to: kind)
        } else {
            result = editor.appendBlock(Block(kind: kind))
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
    
    private func deleteBlock(at indexPath: IndexPath) {
        let block = document.blocks[indexPath.row]
        deleteBlock(block)
    }
    
    private func deleteBlock(_ block: Block) {
        editor.deleteBlock(block)
        updateDataSource(animated: true)
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
        let cell: UICollectionViewCell
        
        switch block.kind {
        case .heading:
            cell = self.headingBlockCell(for: indexPath, block: block)
        case .paragraph:
            cell = self.paragraphBlockCell(for: indexPath, block: block)
        case .quote:
            cell = self.quoteBlockCell(for: indexPath, block: block)
        case .todo:
            cell = self.todoBlockCell(for: indexPath, block: block)
        case .listItem:
            cell = self.bulletedListItemBlockCell(for: indexPath, block: block)
            //cell = self.numberedListItemBlockCell(for: indexPath, block: block)
        case .divider:
            cell = self.dividerBlockCell(for: indexPath, block: block)
        default:
            fatalError("No cell for kind: \(block.kind)")
        }
        
        if let textCell = cell as? BaseTextCellView {
            textCell.delegate = self
            textCell.toolbarController.delegate = self
        }
        
        return cell
    }
    
    private func paragraphBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        let viewModel = TextBlockViewModel(block: block, style: .paragraph)
        cell.configure(with: viewModel)
        return cell
    }
    
    private func headingBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TextBlockCellView.self, for: indexPath)
        let viewModel = TextBlockViewModel(block: block, style: .heading)
        cell.configure(with: viewModel)
        return cell
    }
    
    private func quoteBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(QuoteBlockCellView.self, for: indexPath)
        let viewModel = QuoteBlockViewModel(block: block)
        cell.configure(with: viewModel)
        return cell
    }

    private func todoBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TodoBlockCellView.self, for: indexPath)
        let viewModel = TodoBlockViewModel(block: block)
        cell.configure(with: viewModel)
        cell.todoDelegate = self
        return cell
    }
    
    private func bulletedListItemBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
        let viewModel = ListItemBlockViewModel(block: block, listItemLabelString: "-")
        cell.configure(with: viewModel)
        return cell
    }
    
    private func numberedListItemBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ListItemBlockCellView.self, for: indexPath)
        let viewModel = ListItemBlockViewModel(block: block, listItemLabelString: "1.")
        cell.configure(with: viewModel)
        return cell
    }
    
    private func dividerBlockCell(for indexPath: IndexPath, block: Block) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(DividerBlockCellView.self, for: indexPath)
        let viewModel = DividerBlockViewModel(block: block)
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
        Block.Kind.all.forEach {
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
        
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}

extension DocumentViewController: ToolbarDelegate {
    func toolbarDidTapButton(action: ToolbarAction) {
        switch action {
        case .updateBlockKind(let kind):
            updateEditingBlockKind(to: kind)
        case .dismissKeyboard:
            view.endEditing(true)
        }
    }
    
    private func updateEditingBlockKind(to kind: Block.Kind) {
        guard let block = editingBlock, block.kind != kind else { return }
        
        let result = editor.updateBlockKind(for: block, to: kind)
        applyEditResult(result)
    }
}
