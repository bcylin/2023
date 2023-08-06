import Foundation

/// The API response of `https://swapi.dev/api/films`.
struct FilmListResponse: Decodable {
    var results: [FilmDTO]
}
