@testable import StarWars
import Foundation
import XCTest

final class StubStarWarsService: StarWarsServiceProtocol {

    var stubFetchFilmListResult: Result<[Film], Error>?

    func fetchFilmList() async throws -> [Film] {
        try XCTUnwrap(stubFetchFilmListResult).get()
    }

    var stubFetchCharacterListResult: Result<[People], Error>?

    func fetchCharacterList(in film: Film) async throws -> [People] {
        try XCTUnwrap(stubFetchCharacterListResult).get()
    }
}
