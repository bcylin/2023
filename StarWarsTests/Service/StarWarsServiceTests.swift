@testable import StarWars
import XCTest

final class StarWarsServiceTests: XCTestCase {

    private var apiClient: StubStarWarsAPIClient!
    private var service: StarWarsService!

    override func setUpWithError() throws {
        apiClient = StubStarWarsAPIClient()
        service = StarWarsService(apiClient: apiClient)
    }

    // MARK: - fetchFilmList()

    func testFetchFilmList_success() async throws {
        // Given
        apiClient.stubFetchResults = [
            StarWarsAPIEndpoint.films.url: .success(FilmListResponse.fake(results: Array(repeating: FilmDTO.fake(), count: 3)))
        ]

        // When
        let films = try await service.fetchFilmList()

        // Then
        XCTAssertEqual(films.count, 3)
    }

    func testFetchFilmList_failure() async {
        // Given
        apiClient.stubFetchResults = [
            StarWarsAPIEndpoint.films.url: .failure(NSError())
        ]

        // When
        let expectation = expectation(description: "expect to throw error")
        do {
            _ = try await service.fetchFilmList()
        } catch {
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
    }

    // MARK: - fetchCharacters(in:)

    func testFetchCharacters_success() async throws {
        // Given
        apiClient.stubFetchResults = [
            URL(string: "https://swapi.dev/api/people/2/")!: .success(PeopleDTO.fake(name: "C-3PO")),
            URL(string: "https://swapi.dev/api/people/3/")!: .success(PeopleDTO.fake(name: "R2-D2")),
            URL(string: "https://swapi.dev/api/people/1/")!: .success(PeopleDTO.fake(name: "Luke Skywalker"))
        ]
        let film = Film(dto: .fake(characters: Array(apiClient.stubFetchResults.keys)))

        // When
        let characters = try await service.fetchCharacterList(in: film)

        // Then the characters should be sorted by its URL
        XCTAssertEqual(characters.map(\.name), ["Luke Skywalker", "C-3PO", "R2-D2"])
    }

    func testFetchCharacters_failure() async throws {
        // Given
        apiClient.stubFetchResults = [
            URL(string: "https://swapi.dev/api/people/1/")!: .failure(NSError()),
            URL(string: "https://swapi.dev/api/people/2/")!: .success(PeopleDTO.fake(name: "C-3PO"))
        ]
        let film = Film(dto: .fake(characters: Array(apiClient.stubFetchResults.keys)))

        // When
        let expectation = expectation(description: "expect to throw error")
        do {
            _ = try await service.fetchCharacterList(in: film)
        } catch {
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
    }
}
