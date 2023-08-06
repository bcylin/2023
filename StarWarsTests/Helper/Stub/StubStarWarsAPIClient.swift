@testable import StarWars
import XCTest

final class StubStarWarsAPIClient: StarWarsAPIClientProtocol {

    var stubFetchResults: [URL: Result<Decodable, Error>] = [:]

    func fetch<T: Decodable>(endpoint: StarWarsAPIEndpoint) async throws -> T {
        let result = try stubFetchResults[endpoint.url]?.get()
        return try XCTUnwrap(result as? T)
    }
}
