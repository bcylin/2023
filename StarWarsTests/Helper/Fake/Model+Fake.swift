@testable import StarWars
import Foundation

extension Film {
    static func fake(title: String = "", characterURLs: [URL] = []) -> Self {
        Self(title: title, characterURLs: characterURLs)
    }
}

extension People {
    static func fake(name: String = "", birthYear: String = "") -> Self {
        Self(name: name, birthYear: birthYear)
    }
}
