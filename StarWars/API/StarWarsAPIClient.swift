import Foundation

protocol StarWarsAPIClientProtocol: AnyObject {
    /// Fetch the data from the given API endpoint and decode it as the inferred type.
    ///
    /// - Parameter endpoint: A Star Wars API endpoint.
    /// - Returns: The result of the given type decoded from the fetched data.
    func fetch<T: Decodable>(endpoint: StarWarsAPIEndpoint) async throws -> T
}

final class StarWarsAPIClient: StarWarsAPIClientProtocol {

    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    func fetch<T: Decodable>(endpoint: StarWarsAPIEndpoint) async throws -> T {
        let request = endpoint.request
        let (data, _) = try await session.data(for: request)

        let result = try decoder.decode(T.self, from: data)
        return result
    }
}
