import UIKit

final class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            setBorderColor()
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += 64
        return size
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        setBorderColor()
    }

    private func setUpAppearance() {
        layer.borderWidth = 1
        layer.cornerRadius = 4
        setBorderColor()
        setTitleColor(.label, for: .normal)
        setTitleColor(.tertiaryLabel, for: .highlighted)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }

    private func setBorderColor() {
        layer.borderColor = isHighlighted ? UIColor.tertiaryLabel.cgColor : UIColor.label.cgColor
    }
}
