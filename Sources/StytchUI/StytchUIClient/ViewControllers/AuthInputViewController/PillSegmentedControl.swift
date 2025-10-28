import UIKit

public final class PillSegmentedControl: UIControl {
    public struct Style {
        public var cornerRadius: CGFloat = 12
        public var borderWidth: CGFloat = 1
        public var borderColor: UIColor = .systemGray4
        public var backgroundColorAll: UIColor = .systemBackground
        public var selectedFillColor: UIColor = .systemGray6
        public var dividerColor: UIColor = .systemGray4
        public var textColor: UIColor = .label
        public var font: UIFont = .systemFont(ofSize: 15, weight: .medium)
        public var segmentHeight: CGFloat = 36
        public var contentInsets: NSDirectionalEdgeInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
        public var horizontalPaddingPerSegment: CGFloat = 12
        public var selectionGapFromDivider: CGFloat = 1
        public var selectionVerticalTweak: CGFloat = 0
        public var selectionEdgeNudge: CGFloat = 2

        public init() {}
    }

    public private(set) var selectedIndex: Int = 0

    /// Set an initial selection and observe changes:
    /// segmentedControl.selectedSegmentIndex = 0
    /// segmentedControl.addTarget(self, action: #selector(segmentDidUpdate(sender:)), for: .primaryActionTriggered)
    public var selectedSegmentIndex: Int {
        get { selectedIndex }
        set {
            if segmentButtons.isEmpty {
                pendingSelectedIndex = newValue
            } else {
                setSelectedIndex(newValue, animated: false, sendEvent: false)
                layoutIfNeeded()
                layoutSelection(animated: false)
            }
        }
    }

    public var numberOfSegments: Int {
        segmentButtons.count
    }

    public var style: Style { didSet { applyStyle(); setNeedsLayout() } }

    public var titles: [String] { segmentButtons.map { $0.currentTitle ?? "" } }

    private let containerView = UIView()
    private let segmentsStackView = UIStackView()
    private let selectionHighlightView = UIView()
    private var segmentButtons: [UIButton] = []
    private var segmentDividers: [UIView] = []
    private var equalWidthConstraints: [NSLayoutConstraint] = []
    private var pendingSelectedIndex: Int?

    public override var intrinsicContentSize: CGSize {
        let height = style.contentInsets.top + style.segmentHeight + style.contentInsets.bottom
        return .init(width: UIView.noIntrinsicMetric, height: height)
    }

    public init(titles: [String] = [], style: Style = .init()) {
        self.style = style
        super.init(frame: .zero)
        setup()
        setSegments(titles, selected: 0, sendEvent: false)
    }

    public required init?(coder: NSCoder) {
        style = .init()
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutSelection(animated: false)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        setNeedsLayout()
        layoutIfNeeded()
        layoutSelection(animated: false)
    }

    public func setSegments(_ titles: [String], selected index: Int = 0, sendEvent: Bool = true) {
        clearSegments()
        for segmentIndex in 0..<titles.count {
            let button = makeButton(title: titles[segmentIndex], index: segmentIndex)
            segmentButtons.append(button)
            segmentsStackView.addArrangedSubview(button)
            if segmentIndex < titles.count - 1 {
                let dividerView = makeDivider()
                segmentDividers.append(dividerView)
                segmentsStackView.addArrangedSubview(dividerView)
                applyDividerConstraints(dividerView)
            }
        }
        updateEqualButtonWidths()
        layoutIfNeeded()
        let initialIndex = pendingSelectedIndex ?? index
        pendingSelectedIndex = nil
        setSelectedIndex(initialIndex, animated: false, sendEvent: sendEvent)
        layoutSelection(animated: false)
        updateSelectionCorners()
        applyStyle()
        setNeedsLayout()
        layoutIfNeeded()
    }

    public func setSelectedIndex(_ index: Int, animated: Bool = true, sendEvent: Bool = true) {
        guard !segmentButtons.isEmpty else { return }
        let clampedIndex = max(0, min(index, segmentButtons.count - 1))
        selectedIndex = clampedIndex
        updateButtonStates()
        selectionHighlightView.isHidden = false
        layoutSelection(animated: animated)
        if sendEvent {
            sendActions(for: .valueChanged)
            sendActions(for: .primaryActionTriggered)
        }
    }

    public func insertSegment(withTitle title: String, at index: Int, animated _: Bool = false) {
        let button = makeButton(title: title, index: index)
        if index >= segmentButtons.count {
            segmentButtons.append(button)
            segmentsStackView.addArrangedSubview(button)
        } else {
            segmentsStackView.insertArrangedSubview(button, at: index * 2)
            segmentButtons.insert(button, at: index)
        }

        if segmentButtons.count > 1 {
            let dividerView = makeDivider()
            segmentDividers.append(dividerView)

            let arrangedIndex: Int
            if index >= segmentButtons.count - 1 {
                arrangedIndex = max(0, segmentsStackView.arrangedSubviews.count - 1)
            } else {
                arrangedIndex = index * 2 + 1
            }

            segmentsStackView.insertArrangedSubview(dividerView, at: arrangedIndex)
            applyDividerConstraints(dividerView)
        }

        updateEqualButtonWidths()
        applyStyle()
        setNeedsLayout()
    }

    private func setup() {
        isAccessibilityElement = false

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        containerView.addSubview(selectionHighlightView)
        selectionHighlightView.translatesAutoresizingMaskIntoConstraints = false
        selectionHighlightView.isUserInteractionEnabled = false
        selectionHighlightView.isHidden = false

        segmentsStackView.axis = .horizontal
        segmentsStackView.alignment = .center
        segmentsStackView.distribution = .fill
        segmentsStackView.spacing = 0
        containerView.addSubview(segmentsStackView)
        segmentsStackView.translatesAutoresizingMaskIntoConstraints = false

        func activateStackToContainerConstraints() {
            let leading = segmentsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: style.contentInsets.leading)
            let trailing = segmentsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -style.contentInsets.trailing)
            let top = segmentsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: style.contentInsets.top)
            let bottom = segmentsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -style.contentInsets.bottom)
            leading.priority = UILayoutPriority(999)
            trailing.priority = UILayoutPriority(999)
            top.priority = UILayoutPriority(999)
            bottom.priority = UILayoutPriority(999)
            NSLayoutConstraint.activate([leading, trailing, top, bottom])
        }
        activateStackToContainerConstraints()

        applyStyle()
    }

    private func clearSegments() {
        segmentButtons.forEach { $0.removeFromSuperview() }
        segmentDividers.forEach { $0.removeFromSuperview() }
        segmentButtons.removeAll()
        segmentDividers.removeAll()
        pendingSelectedIndex = nil
        NSLayoutConstraint.deactivate(equalWidthConstraints)
        equalWidthConstraints.removeAll()
        segmentsStackView.arrangedSubviews.forEach { segmentsStackView.removeArrangedSubview($0); $0.removeFromSuperview() }
    }

    private func makeButton(title: String, index _: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = style.font
        button.setTitleColor(style.textColor, for: .normal)
        // Configure using shared helpers
        applyConfiguration(to: button)

        // Keep the configuration in sync for all control states
        button.configurationUpdateHandler = { [weak self] btn in
            guard let self = self else { return }
            self.applyConfiguration(to: btn)
        }
        button.addTarget(self, action: #selector(tapSegment(_:)), for: .touchUpInside)
        button.accessibilityTraits = .button
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }

    private func makeDivider() -> UIView {
        let dividerView = UIView()
        dividerView.backgroundColor = style.dividerColor
        return dividerView
    }

    private func applyDividerConstraints(_ dividerView: UIView) {
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        let width = dividerView.widthAnchor.constraint(equalToConstant: 1)
        let centerY = dividerView.centerYAnchor.constraint(equalTo: segmentsStackView.centerYAnchor)
        let height = dividerView.heightAnchor.constraint(equalTo: segmentsStackView.heightAnchor, constant: -(style.contentInsets.top + style.contentInsets.bottom))
        height.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([width, centerY, height])
    }

    private func updateEqualButtonWidths() {
        // Remove old constraints
        NSLayoutConstraint.deactivate(equalWidthConstraints)
        equalWidthConstraints.removeAll()

        guard segmentButtons.count > 1 else { return }
        let firstButton = segmentButtons[0]
        for button in segmentButtons.dropFirst() {
            let widthConstraint = button.widthAnchor.constraint(equalTo: firstButton.widthAnchor)
            widthConstraint.priority = .required
            equalWidthConstraints.append(widthConstraint)
        }
        NSLayoutConstraint.activate(equalWidthConstraints)
    }

    private func applyStyle() {
        containerView.layer.cornerRadius = style.cornerRadius
        containerView.layer.borderWidth = style.borderWidth
        containerView.layer.borderColor = style.borderColor.cgColor
        containerView.backgroundColor = style.backgroundColorAll
        containerView.clipsToBounds = true

        selectionHighlightView.backgroundColor = style.selectedFillColor
        selectionHighlightView.layer.cornerRadius = max(0, style.cornerRadius - style.borderWidth)
        selectionHighlightView.layer.masksToBounds = true

        for button in segmentButtons {
            button.titleLabel?.font = style.font
            button.setTitleColor(style.textColor, for: .normal)
            applyConfiguration(to: button)
        }
        for dividerView in segmentDividers {
            dividerView.backgroundColor = style.dividerColor
        }
    }

    private func updateButtonStates() {
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = (index == selectedIndex)
            button.isSelected = isSelected
            button.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
        }
    }

    private func frameForSegment(at index: Int) -> CGRect {
        guard index >= 0, index < segmentButtons.count else { return .zero }
        let targetButton = segmentButtons[index]
        let targetFrameInContainer = targetButton.convert(targetButton.bounds, to: containerView)

        let borderInset = max(1, style.borderWidth)
        let horizontalGap = style.selectionGapFromDivider + 0.5

        var leftInset = horizontalGap
        var rightInset = horizontalGap
        if index == 0 { leftInset = borderInset }
        if index == segmentButtons.count - 1 { rightInset = borderInset }

        var selectionFrame = targetFrameInContainer

        // Center the highlight between the outer border and the inner divider.
        let totalHorizontalInset = leftInset + rightInset
        let centeringShift = (rightInset - leftInset) / 2
        selectionFrame.origin.x += leftInset - centeringShift
        selectionFrame.size.width -= totalHorizontalInset
        if index == 0 {
            selectionFrame.origin.x -= style.selectionEdgeNudge
        } else if index == segmentButtons.count - 1 {
            selectionFrame.origin.x += style.selectionEdgeNudge
        }

        let availableHeight = containerView.bounds.height - style.contentInsets.top - style.contentInsets.bottom
        let desiredHeight = min(style.segmentHeight, availableHeight - (borderInset * 2))
        let centeredY = (containerView.bounds.height - desiredHeight) / 2
        selectionFrame.origin.y = centeredY
        selectionFrame.size.height = desiredHeight

        selectionFrame = pixelAligned(selectionFrame)

        return selectionFrame
    }

    private func updateSelectionCorners() {
        // Always round all corners on the selection view so the inner edge is rounded too
        let allCorners: CACornerMask = [
            .layerMinXMinYCorner, .layerMinXMaxYCorner,
            .layerMaxXMinYCorner, .layerMaxXMaxYCorner,
        ]
        selectionHighlightView.layer.maskedCorners = allCorners
        selectionHighlightView.layer.cornerCurve = .continuous

        // Match the container radius on the outside edges, otherwise use a pill radius
        let selectedAtEdge = (selectedIndex == 0 || selectedIndex == max(0, segmentButtons.count - 1))
        let outsideEdgeRadius = max(0, style.cornerRadius - style.borderWidth)
        let pillRadius = min(selectionHighlightView.bounds.height / 2, outsideEdgeRadius)
        selectionHighlightView.layer.cornerRadius = selectedAtEdge ? outsideEdgeRadius : pillRadius
    }

    private func layoutSelection(animated: Bool) {
        let duration: TimeInterval = 0.22
        let newSelectionFrame = frameForSegment(at: selectedIndex)
        if selectionHighlightView.frame == .zero || !animated {
            selectionHighlightView.frame = newSelectionFrame
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
                self.selectionHighlightView.frame = newSelectionFrame
            }
        }
        updateSelectionCorners()
    }

    private func pixelAligned(_ rect: CGRect) -> CGRect {
        guard let scale = window?.screen.scale, scale > 0 else { return rect }
        var result = rect
        result.origin.x = round(result.origin.x * scale) / scale
        result.origin.y = round(result.origin.y * scale) / scale
        result.size.width = round(result.size.width * scale) / scale
        result.size.height = round(result.size.height * scale) / scale
        return result
    }

    private func makeConfiguration(from base: UIButton.Configuration? = nil) -> UIButton.Configuration {
        var configuration = base ?? .plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: style.horizontalPaddingPerSegment, bottom: 0, trailing: style.horizontalPaddingPerSegment)
        configuration.titleAlignment = .center
        configuration.baseForegroundColor = style.textColor
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attrs = incoming
            attrs.font = self.style.font
            attrs.foregroundColor = self.style.textColor
            return attrs
        }
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .clear
        background.strokeColor = .clear
        background.cornerRadius = 0
        configuration.background = background
        return configuration
    }

    private func applyConfiguration(to button: UIButton) {
        button.backgroundColor = .clear
        button.configuration = makeConfiguration(from: button.configuration)
    }

    @objc private func tapSegment(_ sender: UIButton) {
        guard let tappedIndex = segmentButtons.firstIndex(of: sender) else { return }
        setSelectedIndex(tappedIndex, animated: true, sendEvent: true)
    }
}
