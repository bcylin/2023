@testable import StarWars
import XCTest

@MainActor
final class CharacterListViewModelTests: XCTestCase {

    private var context: AppContext!
    private var service: StubStarWarsService!

    private var observation: Observation?
    private var viewRepresentations: [ListViewRepresentation] = []

    override func setUpWithError() throws {
        service = StubStarWarsService()
        context = AppContext(starWarsService: service)
        observation = nil
        viewRepresentations = []
    }

    private func setUpViewModel() async -> CharacterListViewModel {
        let viewModel = CharacterListViewModel(context: context, film: .fake())
        observation = viewModel.viewRepresentation.addObserver(handler: { [weak self] change in
            self?.viewRepresentations.append(change)
        }, shouldInvokeWithInitialValue: false)
        return viewModel
    }

    // MARK: - fetch()

    func testFetch_success() async {
        // Given
        let viewModel = await setUpViewModel()
        service.stubFetchCharacterListResult = .success(Array(repeating: .fake(), count: 10))

        // When
        await viewModel.fetch()

        // Then
        XCTAssertEqual(viewRepresentations.map(\.isLoading), [true, false])
        XCTAssertEqual(viewRepresentations.map(\.snapshot.numberOfItems), [0, 10])
        XCTAssertEqual(viewRepresentations.map(\.errorMessage), [nil, nil])
    }

    func testFetch_failure() async {
        // Given
        let viewModel = await setUpViewModel()
        service.stubFetchCharacterListResult = .failure(NSError())

        // When
        await viewModel.fetch()

        // Then
        XCTAssertEqual(viewRepresentations.map(\.isLoading), [true, false])
        XCTAssertEqual(viewRepresentations.map(\.snapshot.numberOfItems), [0, 0])
        XCTAssertEqual(viewRepresentations.map(\.errorMessage), [nil, NSLocalizedString("error-message", comment: "")])
    }
}
