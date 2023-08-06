import UIKit

import UIKit

/// The main coordinator in this demo that manages a `UISplitViewController` to show a primary view and a detail view.
final class FilmsCoordinator: CoordinatorProtocol {

    init(context: AppContext) {
        self.context = context
    }

    private let splitViewController: UISplitViewController = {
        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        return splitViewController
    }()

    // MARK: - CoordinatorProtocol

    let context: AppContext
    var childCoordinators: [CoordinatorProtocol] = []
    var rootViewController: UIViewController { splitViewController }

    @MainActor
    func start() {
        let viewModel = FilmListViewModel(context: context)
        viewModel.delegate = self
        splitViewController.setViewController(ListViewController(viewModel: viewModel), for: .primary)
    }
}

// MARK: - FilmListViewModelDelegate

extension FilmsCoordinator: FilmListViewModelDelegate {

    @MainActor
    func filmListViewModel(_ viewModel: FilmListViewModel, didSelect film: Film) {
        let viewModel = CharacterListViewModel(context: context, film: film)
        // Clear the navigation stack before showing another detail view
        splitViewController.setViewController(nil, for: .secondary)
        splitViewController.showDetailViewController(ListViewController(viewModel: viewModel), sender: self)
    }
}
