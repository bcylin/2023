import UIKit

/// The base coordinator that manages the `UIWindow` and sets up the dependencies.
final class AppCoordinator: CoordinatorProtocol {

    init(scene: UIScene? = nil) {
        if let windowScene = (scene as? UIWindowScene) {
            self.window = UIWindow(windowScene: windowScene)
        } else {
            self.window = nil
        }

        let apiClient = StarWarsAPIClient()
        self.context = AppContext(starWarsService: StarWarsService(apiClient: apiClient))
    }

    let window: UIWindow?

    private lazy var filmsCoordinator = FilmsCoordinator(context: context)

    // MARK: - CoordinatorProtocol

    let context: AppContext
    lazy var childCoordinators: [CoordinatorProtocol] = [filmsCoordinator]
    var rootViewController: UIViewController { filmsCoordinator.rootViewController }

    @MainActor
    func start() {
        childCoordinators.forEach { $0.start() }
        window?.backgroundColor = .systemBackground
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
