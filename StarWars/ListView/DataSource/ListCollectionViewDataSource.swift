import UIKit

/// The `UICollectionViewDataSource` that defines the cell configuration in the list collection view.
final class ListCollectionViewDataSource: UICollectionViewDiffableDataSource<Section, CellConfiguration> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellConfiguration>
}

/// The `SectionIdentifierType` used in the compositional list layout.
///
/// The ``Section`` and ``CellConfiguration`` could be declared inside a namespace if there are more than one type of list.
/// They are declared in the top level for simplicity.
enum Section: Hashable {
    case main
}

/// The `ItemIdentifierType` used in the compositional list layout.
struct CellConfiguration: Hashable {
    var identifier = UUID()
    var title: String
    var subtitle: String
}
