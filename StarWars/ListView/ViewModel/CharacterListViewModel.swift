import Foundation

@MainActor
final class CharacterListViewModel {

    init(context: AppContext, film: Film) {
        self.film = film
        self.title = film.title
        self.starWarsService = context.starWarsService
    }

    private let film: Film
    private let starWarsService: StarWarsServiceProtocol
    @Observable private var _viewRepresentation = ListViewRepresentation()

    private var variables = ListViewModelVariables<People>() {
        didSet {
            guard variables != oldValue else { return }
            rebuildViewRepresentation()
        }
    }

    let title: String
    var viewRepresentation: Observable<ListViewRepresentation> { $_viewRepresentation }

    func fetch() async {
        guard variables.state != .loading else { return }
        variables.state = .loading

        do {
            variables.items = try await starWarsService.fetchCharacterList(in: film)
        } catch {
            variables.state = Task.isCancelled ? .loaded : .error
        }
    }

    func selectItem(at index: Int) {
        // Do nothing
    }

    // MARK: - Private

    private func rebuildViewRepresentation() {
        var viewRepresentation = ListViewRepresentation(loadingState: variables.state)

        var snapshot = ListCollectionViewDataSource.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(variables.items.map(CellConfiguration.init(people:)), toSection: .main)
        viewRepresentation.snapshot = snapshot

        self._viewRepresentation = viewRepresentation
    }
}

// MARK: - Private

private extension CellConfiguration {
    init(people: People) {
        title = people.name
        subtitle = String(format: NSLocalizedString("character-birth-year", comment: ""), people.birthYear)
    }
}
