@testable import StarWars
import Foundation

final class MockFilmListViewModelDelegate: FilmListViewModelDelegate {

    enum Invocation: Equatable {
        case didSelectFilm(Film)
    }

    private(set) var invocations: [Invocation] = []

    func filmListViewModel(_ viewModel: FilmListViewModel, didSelect film: Film) {
        invocations.append(.didSelectFilm(film))
    }
}
