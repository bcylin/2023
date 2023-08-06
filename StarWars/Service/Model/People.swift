import Foundation

/// The character model returned from the ``StarWarsService``.
struct People: Equatable {
    var name: String
    var birthYear: String
}

extension People {
    init(dto: PeopleDTO) {
        self.name = dto.name
        self.birthYear = dto.birthYear
    }
}
