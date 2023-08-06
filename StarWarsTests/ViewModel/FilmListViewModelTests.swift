@testable import StarWars
import XCTest

@MainActor
final class FilmListViewModelTests: XCTestCase {

    private var context: AppContext!
    private var service: StubStarWarsService!
    private var delegate: MockFilmListViewModelDelegate!

    private var observation: Observation?
    private var viewRepresentations: [ListViewRepresentation] = []

    override func setUpWithError() throws {
        service = StubStarWarsService()
        context = AppContext(starWarsService: service)
        delegate = MockFilmListViewModelDelegate()
        observation = nil
        viewRepresentations = []
    }

    private func setUpViewModel(with preloadedFilms: [Film]? = nil) async -> FilmListViewModel {
        let viewModel = FilmListViewModel(context: context)
        viewModel.delegate = delegate

        if let preloadedFilms {
            service.stubFetchFilmListResult = .success(preloadedFilms)
            await viewModel.fetch()
        } else {
            observation = viewModel.viewRepresentation.addObserver(handler: { [weak self] change in
                self?.viewRepresentations.append(change)
            }, shouldInvokeWithInitialValue: false)
        }

        return viewModel
    }

    // MARK: - fetch()

    func testFetch_success() async {
        // Given
        let viewModel = await setUpViewModel()
        service.stubFetchFilmListResult = .success(Array(repeating: .fake(), count: 3))

        // When
        await viewModel.fetch()

        // Then
        XCTAssertEqual(viewRepresentations.map(\.isLoading), [true, false])
        XCTAssertEqual(viewRepresentations.map(\.snapshot.numberOfItems), [0, 3])
        XCTAssertEqual(viewRepresentations.map(\.errorMessage), [nil, nil])
    }

    func testFetch_failure() async {
        // Given
        let viewModel = await setUpViewModel()
        service.stubFetchFilmListResult = .failure(NSError())

        // When
        await viewModel.fetch()

        // Then
        XCTAssertEqual(viewRepresentations.map(\.isLoading), [true, false])
        XCTAssertEqual(viewRepresentations.map(\.snapshot.numberOfItems), [0, 0])
        XCTAssertEqual(viewRepresentations.map(\.errorMessage), [nil, NSLocalizedString("error-message", comment: "")])
    }

    // MARK: - selectItem(at:)

    func testSelectItemAtIndex() async {
        // Given
        let viewModel = await setUpViewModel(with: [.fake(), .fake(title: #function), .fake()])

        // When
        viewModel.selectItem(at: 1)

        // Then
        XCTAssertEqual(delegate.invocations, [.didSelectFilm(.fake(title: #function))])
    }

    func testSelectItemAtIndex_outOfRange() async {
        // Given
        let viewModel = await setUpViewModel(with: [.fake()])

        // When
        viewModel.selectItem(at: 2)

        // Then it shouldn't trigger navigation
        XCTAssertEqual(delegate.invocations, [])
    }
}
