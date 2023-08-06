import Foundation

/// The film model returned from the ``StarWarsService``.
struct Film: Equatable {
    var title: String
    var characterURLs: [URL]

    var numberOfCharacters: Int { characterURLs.count }
}

extension Film {
    init(dto: FilmDTO) {
        self.title = dto.title
        self.characterURLs = dto.characters
    }
}
