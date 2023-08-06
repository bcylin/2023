import Foundation

/// The API response of `https://swapi.dev/api/people/:id`.
struct PeopleDTO: Decodable {
    var name: String
    var birthYear: String
}
