import UIKit

/// The view controller that shows a list of items in a collection view.
final class ListViewController: UIViewController {

    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fetchingTask?.cancel()
    }

    /// Mimic UICollectionViewController.clearsSelectionOnViewWillAppear behaviour
    var clearsSelectionOnViewWillAppear: Bool = true

    private let viewModel: ListViewModelProtocol
    private var observation: Observation?
    private var fetchingTask: Task<(), Never>?

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refetch), for: .valueChanged)
        return refreshControl
    }()

    private let collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var dataSource = ListCollectionViewDataSource(collectionView: collectionView, viewModel: viewModel)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureDataSource()
        refetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard clearsSelectionOnViewWillAppear else { return }
        collectionView.indexPathsForSelectedItems?.forEach { indexPath in
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Disable clearsSelectionOnViewWillAppear when the window is wider enough to show two columns
        clearsSelectionOnViewWillAppear = view.window?.traitCollection.horizontalSizeClass == .compact
    }

    private func configureViewHierarchy() {
        // Show a bottom border on the navigation bar to mimic the classic iOS style
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        collectionView.refreshControl = refreshControl
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    private func configureDataSource() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        observation = viewModel.viewRepresentation.addObserver(handler: { [weak self] changes in
            self?.updateUI(with: changes)
        }, shouldInvokeWithInitialValue: true)
    }

    private func updateUI(with viewRepresentation: ListViewRepresentation) {
        if refreshControl.isRefreshing != viewRepresentation.isLoading {
            viewRepresentation.isLoading ? refreshControl.beginRefreshing() : refreshControl.endRefreshing()
        }

        let isInitialUpdate = dataSource.numberOfSections(in: collectionView) == 0
        dataSource.apply(viewRepresentation.snapshot, animatingDifferences: isInitialUpdate)

        // TODO: show error
    }

    @objc private func refetch() {
        fetchingTask = Task { [viewModel] in
            await viewModel.fetch()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        viewModel.allowsItemSelection
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath.item)
    }
}
