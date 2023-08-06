import UIKit

protocol CoordinatorProtocol: AnyObject {
    /// The dependencies to pass around coordinators.
    var context: AppContext { get }

    /// An array of coordinators that are children of the current coordinator.
    var childCoordinators: [CoordinatorProtocol] { get set }

    /// The root view controller that the coordinator manages.
    var rootViewController: UIViewController { get }

    /// The method to start a coordinator flow.
    func start()
}
