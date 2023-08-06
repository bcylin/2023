import Foundation

@MainActor
/// The common interface of the view model for ``ListViewController``.
protocol ListViewModelProtocol: AnyObject {
    /// The title of the view controller.
    var title: String { get }

    /// A boolean that indicates whether the items in the list is selectable.
    var allowsItemSelection: Bool { get }

    /// An ``Observable`` property for the view controller to update the UI.
    var viewRepresentation: Observable<ListViewRepresentation> { get }

    /// The method to fetch the list of items to show in the view controller.
    func fetch() async

    /// The method of action when an item in the list is selected.
    func selectItem(at index: Int)
}
