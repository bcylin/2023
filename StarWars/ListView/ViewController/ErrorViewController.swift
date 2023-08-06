import UIKit

protocol ErrorViewControllerDelegate: AnyObject {
    func errorViewControllerDidSelectRetry(_ controller: ErrorViewController)
}

/// The error view with a retry button to refetch the list.
final class ErrorViewController: UIViewController {

    weak var delegate: ErrorViewControllerDelegate?

    var errorMessage: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }

    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = RoundedButton()
        button.setTitle(NSLocalizedString("error-retry", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        stackView.spacing = 32
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
    }

    private func configureViewHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(retryButton)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor)
        ])
    }

    @objc private func retry(_ sender: UIButton) {
        delegate?.errorViewControllerDidSelectRetry(self)
    }
}
