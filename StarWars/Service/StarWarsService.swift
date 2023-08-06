import Foundation

protocol StarWarsServiceProtocol: AnyObject {
    /// Fetch a list of Star Wars films.
    func fetchFilmList() async throws -> [Film]

    /// Fetch a list of characters of a given film.
    func fetchCharacterList(in film: Film) async throws -> [People]
}

final class StarWarsService: StarWarsServiceProtocol {

    init(apiClient: StarWarsAPIClientProtocol) {
        self.apiClient = apiClient
    }

    private let apiClient: StarWarsAPIClientProtocol
    private typealias Key = String

    // MARK: - StarWarsServiceProtocol

    func fetchFilmList() async throws -> [Film] {
        let response: FilmListResponse = try await apiClient.fetch(endpoint: .films)
        return response.results.map(Film.init(dto:))
    }

    func fetchCharacterList(in film: Film) async throws -> [People] {
        var characters: [Key: People] = [:]

        try await withThrowingTaskGroup(of: (Key, PeopleDTO).self) { [apiClient] group in
            // Create child tasks in the group to execute in parallel
            for endpoint in film.characterEndpoints {
                try Task.checkCancellation()
                group.addTask {
                    return (endpoint.url.absoluteString, try await apiClient.fetch(endpoint: endpoint))
                }
            }

            // The parent task retrieves the results from each child task sequentially after they finish fetching
            for try await (key, dto) in group {
                characters[key] = People(dto: dto)
            }
        }

        // Return the characters in a fixed order
        return characters.keys.sorted().compactMap { characters[$0] }
    }
}

// MARK: -

private extension Film {
    var characterEndpoints: [StarWarsAPIEndpoint] {
        characterURLs.map { .people($0) }
    }
}
