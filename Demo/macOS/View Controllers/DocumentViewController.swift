import Cocoa
import Combine
import Pilcrow

final class DocumentViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private lazy var editor = DocumentEditor(document: .test)
    private var document: Document { editor.document }
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
        configureEditor()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        // TODO: I don't think this should be necessary, as it correctly invalidates while resizing
        // but didn't seem to correctly invalidate on first layout
        collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    // MARK: - Editing
    
    private func configureEditor() {
        editor.changes
            .sink { [weak self] editResult in
                self?.applyEditResult(editResult)
            }
            .store(in: &subscriptions)
    }
    
    private func applyEditResult(_ result: EditResult) {
        print("[DocumentViewController] applyEditResult: \(result)")
        
        switch result {
        case .inserted(let id):
            updateDataSource()
            let block = document.blocks.first(where: { $0.id == id })!
            focusBlock(block)
            collectionView.collectionViewLayout?.invalidateLayout()
        case .updatedContent(let id):
            //let block = document.blocks.first(where: { $0.id == id })!
            //reconfigureBlocks([block])
            //updateDataSource()
            // Ensure cells are resized while typing
            // TODO: figure out how to update single row that changed
            collectionView.collectionViewLayout?.invalidateLayout()
        case .updatedKind(let id):
            let block = document.block(with: id)!
            updateDataSource()
            focusBlock(block)
        case .deleted(let id, let index):
            updateDataSource()
            collectionView.collectionViewLayout?.invalidateLayout()
            focusCell(before: index)
        case .moved:
            updateDataSource()
        }
    }
    
    // MARK: - Collection View
    
    private func makeLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(22))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        section.interGroupSpacing = 5

        return NSCollectionViewCompositionalLayout(section: section)
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        collectionView.isSelectable = true
        //collectionView.delegate = self
        collectionView.backgroundColors = [.clear]
    }
    
    // MARK: - Data Source
    
    private var dataSource: NSCollectionViewDiffableDataSource<Section, Block.ID>!
    
    private func configureDataSource() {
        collectionView.register(BaseTextCollectionViewItem.self, forItemWithIdentifier: BaseTextCollectionViewItem.reuseIdentifier)

        dataSource = NSCollectionViewDiffableDataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, id in
            guard let block = document.block(with: id) else {
                return nil
            }
            
            guard let item = collectionView.makeItem(withIdentifier: BaseTextCollectionViewItem.reuseIdentifier, for: indexPath) as? BaseTextCollectionViewItem else {
                return nil
            }
            
            item.configure(with: block)
            item.delegate = self
            
            return item
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
        print("updateDataSource()")
        dataSource.apply(makeSnapshot(), animatingDifferences: animated)
    }
    
    // MARK: - Cells
    
    private func block(for cell: NSCollectionViewItem) -> Block? {
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        return document.block(at: indexPath.item)
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
        guard let cell = collectionView.item(at: indexPath) as? BaseTextCollectionViewItem else { return }
        cell.focus()
    }
}

extension DocumentViewController {
    enum Section {
        case main
    }
}

extension DocumentViewController: TextCellDelegate {
    func textCellDidEdit(cell: NSCollectionViewItem, edit: TextEdit) {
        print("[DocumentViewController] cell did edit: \(edit)")
        guard let block = block(for: cell) else { return }
        editor.apply(edit: edit, to: block)
    }
}
