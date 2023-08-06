import Foundation

/// A property wrapper that observes the value changes.
///
/// Usage:
///
/// ```swift
/// class ViewModel {
///     @Observable private(set) var viewRepresentation = ListViewRepresentation()
/// }
///
/// class ViewController {
///     let viewModel = ViewModel()
///     lazy var observation = viewModel.$viewRepresentation.addObserver { change in ... }
/// }
/// ```
///
/// As the use of **Combine** should be avoided in this tech test,
/// this property wrapper provides a similar functionality of the built-in `@Published` property wrapper.
/// The only difference is the handler closure is executed at `didSet` instead of `willSet`.
///
/// This implementation can be completely replaced by `@Published`.
@propertyWrapper final class Observable<T> {
    typealias Change = T

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    private var observers: [ObjectIdentifier: Observer<Change>] = [:]

    var wrappedValue: T {
        didSet {
            observers.values.forEach { $0.handler(wrappedValue) }
        }
    }

    var projectedValue: Observable {
        self
    }

    /// Add an observer to observe the changes of the ``wrappedValue``.
    ///
    /// - Parameters:
    ///   - handler: The closure to execute when the ``wrappedValue`` changes.
    ///   - shouldInvokeWithInitialValue: A boolean that indicates whether the handler should be invoked with the initial value.
    /// - Returns: A cancellable ``Observation`` instance.
    func addObserver(handler: @escaping (Change) -> Void, shouldInvokeWithInitialValue: Bool = true) -> Observation {
        let observer = Observer(handler: handler)
        let id = ObjectIdentifier(observer)
        observers[id] = observer

        if shouldInvokeWithInitialValue {
            handler(wrappedValue)
        }
        return Observation(cancel: { [weak self] in
            self?.observers.removeValue(forKey: id)
        })
    }
}

// MARK: -

/// A wrapper that executes the ``cancel`` closure when the instance deallocates.
///
/// Usage:
///
/// ```
/// observation.cancel()
/// ```
final class Observation {
    let cancel: () -> Void

    init(cancel: @escaping () -> Void) {
        self.cancel = cancel
    }

    deinit {
        cancel()
    }
}

// MARK: - Private

/// A wrapper for the change handler.
private final class Observer<Change> {
    let handler: (Change) -> Void

    init(handler: @escaping (Change) -> Void) {
        self.handler = handler
    }
}

