# StarWars

A demo app to show a list of Star Wars films and characters of each film.

## Project Setup

```sh
cd StarWars && open StarWars.xcworkspace
```

- No 3rd party dependencies
- Built with Xcode 14.3.1
- Deployment targeting iOS 14.0 to use the latest collection view API

## Assumptions

- Pagination is not required
- Data persistence is not required
- The character list only shows when all the characters are successfully retrieved. (To display a partial list, it requires a different set of logic in the implementation)

## App Structure

The app is built using the MVVM-C pattern.

### Coordinator

Coordinators are responsible for the navigation flows. `CoordinatorProtocol` defines the common interface. Using coordinators makes it easy to change the hierarchy. For example, if later it requires a tab bar UI, simply replace the FilmsCoordinator with a TabCoordinator.

- `AppCoordinator`, the base coordinator that manages the UIWindow. It also sets up the dependencies in `AppContext` and starts its child coordinator flows.

- `FilmsCoordinator`, the main coordinator in this demo app. It manages a UISplitViewController to show two columns on iPad and a primary-detail flow on iPhone.

### API & Service

- `StarWarsAPIClient` sends the URLRequest and parses the response as Decodable DTOs.

- `StarWarsService` provides two convenient methods to fetch specific lists of items and maps the DTOs to the Models used in other parts of the app.

### View Model

The two lists in the app have similar logic. They are displayed in the same view controller. `ListViewModelProtocol` defines the common interface required by the ListViewController.

It's possible that the view models can be refactored into a single generic type that is associated with its Model type. However, I decided to keep it simple as two separate classes due to the limited time. The code duplication should be relatively minimal.

The Models are converted into `CellConfiguration` in the view model layer. The UI state is described as `ListViewRepresentation`. The view model notifies the view controller to update the UI when the state changes. The view model also delegates the navigation back to the coordinator layer.

- `FilmListViewModel` fetches the list of Star Wars films and handles the item selection to show the characters of each film.

- `CharacterListViewModel` fetches the list of characters of a given film.

### View Controller

The UI consists of three states:

```swift
enum LoadingState {
    case loading
    case loaded
    case error
}
```

Loading|Loaded Film List|Loaded Character List|Error
:---:|:---:|:---:|:---:
<img src="https://user-images.githubusercontent.com/2032500/258657905-db59b2c6-c7e6-4094-9086-532720d1beb4.png" width="200" />|<img src="https://user-images.githubusercontent.com/2032500/258657907-3f618b18-1cc8-4fbd-a063-ff884262b1e5.png" width="200" />|<img src="https://user-images.githubusercontent.com/2032500/258657910-0cdbcf78-e409-4f10-8e5d-c5ee3e620e5c.png" width="200" />|<img src="https://user-images.githubusercontent.com/2032500/258657909-4ace02f6-11d8-437b-8189-1fb908e14c6e.png" width="200" />

- `ListViewController` shows the items in the list compositional layout. It's using the UICollectionViewDiffableDataSource and configures the cells with CellRegistration API. I decided to use the system default cell style as this demo focuses on the app structure.

- `ErrorViewController` shows an error message and a retry button when the API request fails. The layout is built using layout constraints and supports the basic dynamic fonts and dark mode.

## Design Decisions

### No persistence layer

Since the data is relatively simple in this demo app, I decided to focus on other parts like tests. Due to the limited time, I think it's a valid trade-off to omit the persistence layer.

### Observable

The view model communicates to the coordinator via delegation to forward the navigation actions. It also needs to communicate to the view controller about the UI updates. It's usually done via a reactive binding. However, the specification requires reactive frameworks such as Combine to be avoided.

I could've used delegation with a weak `uiDelegate` but it feels a bit clunky to have multiple delegates. I decided to use an `@Observable` property wrapper for a closure-based mechanism to get the data changes. It provides a simple way for the view controller to observe view model changes to update the UI.

```swift
class ViewModel {
    @Observable private(set) var viewRepresentation = ListViewRepresentation()
}

class ViewController {
    let viewModel = ViewModel()
    lazy var observation = viewModel.$viewRepresentation.addObserver { change in ... }
}
```

### Structured concurrency

Both `StarWarsAPIClient` and `StarWarsService` are using Swift async await concurrency. It simplifies the logic to jump between threads, especially when fetching the character list, it waits until all the requests come back before it returns. The task group replaces the prior mechanisms such as DispatchGroup or DispatchSemaphore. The throwing error also makes sure all the edge cases are caught during the compile time.

### Tests

The tests are set up by injecting mock dependencies.

- `StarWarsServiceTests` use StubStarWarsAPIClient to fake the API response and verify the list of characters is returned in a fixed order.

- `Film/CharacterViewModelTests` use StubStarWarsService to fake the Models returned from the API and verify the view representation shows the correct state changes. MockFilmListViewModelDelegate is also used to check if the correct navigation flow is triggered via the item selection.

## Improvements

- First of all, the UI can definitely be improved to show more info in the list. The compositional layout can be changed to image grids to be more visually compelling. The error messages can also be more specific in different scenarios.

- There's no persistence layer in this demo app. Ideally, the service can store the fetched data in a Repository, then the Repository notifies the view model about the data changes to update the UI. The Repository acts as the persistence layer. It can implement an in-memory cache to improve the performance by not having to fetching the same list again. The abstract layer also makes it easier to change the implementation to other database solutions later if needed.

    ```
    // Ideal data flow

    View model -> Service -> store data in Repository
        ^                                    │
        └──────── notify of changes ─────────┘
    ```

- Some of the shared behaviours between FilmListViewModel and CharacterListViewModel can be further moved into a generic implementation. For example, the `func fetch() async` logic can be reused with an associated type to represent both `[Film]` and `[People]`.

- I didn't add UI tests as the Star Wars API is slow so the tests might be flaky. The StubStarWarsAPIClient can provide fake responses to make UI tests run smoother. However, it requires additional setups in the testing target.

- The DTO and Model's fake methods used in the tests can be auto-generated by [Sourcery](https://github.com/krzysztofzablocki/Sourcery) or [Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) in Swift 5.9 beta.
