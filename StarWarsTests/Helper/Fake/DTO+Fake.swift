@testable import StarWars
import Foundation

// These fake methods can be generated using Sourcery or Swift macros in Xcode 15 beta.

extension FilmListResponse {
    static func fake(results: [FilmDTO] = []) -> Self {
        Self(results: results)
    }
}

extension FilmDTO {
    static func fake(title: String = "", characters: [URL] = []) -> Self {
        Self(title: title, characters: characters)
    }
}

extension PeopleDTO {
    static func fake(name: String = "", birthYear: String = "") -> Self {
        Self(name: name, birthYear: birthYear)
    }
}
