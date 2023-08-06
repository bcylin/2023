import Foundation

/// The structure of each item in `https://swapi.dev/api/films`.
struct FilmDTO: Decodable {
    var title: String
    var characters: [URL]
}
