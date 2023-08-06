import Foundation

/// A group of dependencies required in the app, although there's only one in this demo.
struct AppContext {
    let starWarsService: StarWarsServiceProtocol
}
