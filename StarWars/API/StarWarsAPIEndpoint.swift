import Foundation

enum StarWarsAPIEndpoint {
    case films          // https://swapi.dev/api/films/
    case people(URL)    // https://swapi.dev/api/people/:id/

    // Force unwrap the URL here. Any error should be caught during development.
    static let baseURL = URL(string: "https://swapi.dev/api/")!

    var url: URL {
        switch self {
        case .films:
            return Self.baseURL.appendingPathComponent("films")
        case .people(let url):
            return url
        }
    }

    var request: URLRequest {
        return URLRequest(url: url)
    }
}
