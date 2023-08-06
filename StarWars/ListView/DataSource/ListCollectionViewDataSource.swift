import UIKit

/// The `UICollectionViewDataSource` that defines the cell configuration in the list collection view.
final class ListCollectionViewDataSource: UICollectionViewDiffableDataSource<Section, CellConfiguration> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellConfiguration>

    convenience init(collectionView: UICollectionView, viewModel: ListViewModelProtocol) {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CellConfiguration> { cell, indexPath, item in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            cell.contentConfiguration = contentConfiguration

            if viewModel.allowsItemSelection {
                cell.accessories = [.disclosureIndicator()]
            }
        }

        self.init(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
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
