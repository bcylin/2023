import Foundation

/// A group of variables in the list view model.
struct ListViewModelVariables<Item: Equatable>: Equatable {
    var state: LoadingState = .initial
    var items: [Item] = [] {
        didSet {
            state = .loaded
        }
    }
}

/// The possible loading states in the list view.
enum LoadingState: Equatable {
    case initial
    case loading
    case loaded
    case error
}
