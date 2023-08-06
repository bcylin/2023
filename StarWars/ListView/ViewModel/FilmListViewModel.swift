import Foundation

protocol FilmListViewModelDelegate: AnyObject {
    func filmListViewModel(_ viewModel: FilmListViewModel, didSelect film: Film)
}

@MainActor
final class FilmListViewModel: ListViewModelProtocol {

    init(context: AppContext) {
        self.starWarsService = context.starWarsService
    }

    weak var delegate: FilmListViewModelDelegate?

    private let starWarsService: StarWarsServiceProtocol
    @Observable private var _viewRepresentation = ListViewRepresentation()

    private var variables = ListViewModelVariables<Film>() {
        didSet {
            guard variables != oldValue else { return }
            rebuildViewRepresentation()
        }
    }

    // MARK: - ListViewModelProtocol

    let title: String = NSLocalizedString("star-wars", comment: "")
    let allowsItemSelection: Bool = true
    var viewRepresentation: Observable<ListViewRepresentation> { $_viewRepresentation }

    func fetch() async {
        guard variables.state != .loading else { return }
        variables.state = .loading

        do {
            variables.items = try await starWarsService.fetchFilmList()
        } catch {
            variables.state = Task.isCancelled ? .loaded : .error
        }
    }

    func selectItem(at index: Int) {
        guard variables.items.indices.contains(index) else { return }
        delegate?.filmListViewModel(self, didSelect: variables.items[index])
    }

    // MARK: - Private

    private func rebuildViewRepresentation() {
        var viewRepresentation = ListViewRepresentation(loadingState: variables.state)

        var snapshot = ListCollectionViewDataSource.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(variables.items.map(CellConfiguration.init(film:)), toSection: .main)
        viewRepresentation.snapshot = snapshot

        self._viewRepresentation = viewRepresentation
    }
}

// MARK: - Private

private extension CellConfiguration {
    init(film: Film) {
        title = film.title
        subtitle = String(format: NSLocalizedString("character-count", comment: ""), film.numberOfCharacters)
    }
}
