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

    func start() {
        // TODO:
    }
}
