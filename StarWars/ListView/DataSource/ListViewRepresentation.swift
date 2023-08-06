import Foundation

/// The UI representation of a list view with initial values.
struct ListViewRepresentation {
    /// A boolean that indicates whether to show the `UIRefreshControl` in the collection view.
    var isLoading: Bool = false

    /// The diffable snapshot of the items in the list.
    var snapshot = ListCollectionViewDataSource.Snapshot()

    /// A variable that indicates whether the list should display an error message.
    var errorMessage: String? = nil
}

extension ListViewRepresentation {
    init(loadingState: LoadingState) {
        switch loadingState {
        case .initial:
            break
        case .loading:
            isLoading = true
            errorMessage = nil
        case .loaded:
            isLoading = false
            errorMessage = nil
        case .error:
            isLoading = false
            errorMessage = NSLocalizedString("error-message", comment: "")
        }
    }
}
