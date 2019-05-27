//
//  DropDown.swift
//  DropDown
//
//  Created by Kevin Hirsch, revision history on Githbub.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

public typealias Index = Int
public typealias Closure = () -> Void
public typealias SelectionClosure = (Index, String) -> Void
public typealias ConfigurationClosure = (Index, String) -> String
public typealias CellConfigurationClosure = (Index, String, DropDownCell) -> Void
private typealias ComputeLayoutTuple = (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat)

/// Can be `UIView` or `UIBarButtonItem`.
@objc
public protocol AnchorView: class {

	var plainView: UIView { get }

}

extension UIView: AnchorView {

	public var plainView: UIView {
		return self
	}

}

extension UIBarButtonItem: AnchorView {

	public var plainView: UIView {
		return value(forKey: "view") as! UIView
	}

}

/// A Material Design drop down in replacement for `UIPickerView`.
public final class DropDown: UIView {

	//TODO: handle iOS 7 landscape mode

	/// The dismiss mode for a drop down.
	public enum DismissMode {

		/// A tap outside the drop down is required to dismiss.
		case onTap

		/// No tap is required to dismiss, it will dimiss when interacting with anything else.
		case automatic

		/// Not dismissable by the user.
		case manual

	}

	/// The direction where the drop down will show from the `anchorView`.
	public enum Direction {

		/// The drop down will show below the anchor view when possible, otherwise above if there is more place than below.
		case any

		/// The drop down will show above the anchor view or will not be showed if not enough space.
		case top

		/// The drop down will show below or will not be showed if not enough space.
		case bottom

	}

	// MARK: - Properties

	/// The current visible drop down. There can be only one visible drop down at a time.
	public static weak var VisibleDropDown: DropDown?

	// MARK: UI
	fileprivate let dismissableView = UIView()
	fileprivate let tableViewContainer = UIView()
	fileprivate let tableView = UITableView()
	fileprivate var templateCell: DropDownCell!

	/// The view to which the drop down will displayed onto.
	public weak var anchorView: AnchorView? {
		didSet { setNeedsUpdateConstraints() }
	}

	/**
	The possible directions where the drop down will be showed.

	See `Direction` enum for more info.
	*/
	public var direction = Direction.any

	/**
	The offset point relative to `anchorView` when the drop down is shown above the anchor view.

	By default, the drop down is showed onto the `anchorView` with the top
	left corner for its origin, so an offset equal to (0, 0).
	You can change here the default drop down origin.
	*/
	public var topOffset: CGPoint = .zero {
		didSet { setNeedsUpdateConstraints() }
	}

	/**
	The offset point relative to `anchorView` when the drop down is shown below the anchor view.

	By default, the drop down is showed onto the `anchorView` with the top
	left corner for its origin, so an offset equal to (0, 0).
	You can change here the default drop down origin.
	*/
	public var bottomOffset: CGPoint = .zero {
		didSet { setNeedsUpdateConstraints() }
	}

	/**
	The width of the drop down.

	Defaults to `anchorView.bounds.width - offset.x`.
	*/
	public var width: CGFloat? {
		didSet { setNeedsUpdateConstraints() }
	}

	// MARK: Constraints
	fileprivate var heightConstraint: NSLayoutConstraint!
	fileprivate var widthConstraint: NSLayoutConstraint!
	fileprivate var xConstraint: NSLayoutConstraint!
	fileprivate var yConstraint: NSLayoutConstraint!

	// MARK: Appearance
    @objc public dynamic var cellHeight = DPDConstant.UI.RowHeight {
		willSet { tableView.rowHeight = newValue }
		didSet { reloadAllComponents() }
	}

    @objc fileprivate dynamic var tableViewBackgroundColor = DPDConstant.UI.BackgroundColor {
		willSet { tableView.backgroundColor = newValue }
	}

	public override var backgroundColor: UIColor? {
		get { return tableViewBackgroundColor }
		set { tableViewBackgroundColor = newValue! }
	}

	/**
	The background color of the selected cell in the drop down.

	Changing the background color automatically reloads the drop down.
	*/
    @objc public dynamic var selectionBackgroundColor = DPDConstant.UI.SelectionBackgroundColor

	/**
	The separator color between cells.

	Changing the separator color automatically reloads the drop down.
	*/
    @objc public dynamic var separatorColor = DPDConstant.UI.SeparatorColor {
		willSet { tableView.separatorColor = newValue }
		didSet { reloadAllComponents() }
	}

	/**
	The corner radius of DropDown.

	Changing the corner radius automatically reloads the drop down.
	*/
    @objc public dynamic var cornerRadius = DPDConstant.UI.CornerRadius {
		willSet {
			tableViewContainer.layer.cornerRadius = newValue
			tableView.layer.cornerRadius = newValue
		}
		didSet { reloadAllComponents() }
	}

	/**
	The color of the shadow.

	Changing the shadow color automatically reloads the drop down.
	*/
    @objc public dynamic var shadowColor = DPDConstant.UI.Shadow.Color {
		willSet { tableViewContainer.layer.shadowColor = newValue.cgColor }
		didSet { reloadAllComponents() }
	}

	/**
	The offset of the shadow.

	Changing the shadow color automatically reloads the drop down.
	*/
    @objc public dynamic var shadowOffset = DPDConstant.UI.Shadow.Offset {
		willSet { tableViewContainer.layer.shadowOffset = newValue }
		didSet { reloadAllComponents() }
	}

	/**
	The opacity of the shadow.

	Changing the shadow opacity automatically reloads the drop down.
	*/
    @objc public dynamic var shadowOpacity = DPDConstant.UI.Shadow.Opacity {
		willSet { tableViewContainer.layer.shadowOpacity = newValue }
		didSet { reloadAllComponents() }
	}

	/**
	The radius of the shadow.

	Changing the shadow radius automatically reloads the drop down.
	*/
    @objc public dynamic var shadowRadius = DPDConstant.UI.Shadow.Radius {
		willSet { tableViewContainer.layer.shadowRadius = newValue }
		didSet { reloadAllComponents() }
	}

	/**
	The duration of the show/hide animation.
	*/
    @objc public dynamic var animationduration = DPDConstant.Animation.Duration

	/**
	The option of the show animation. Global change.
	*/
	public static var animationEntranceOptions = DPDConstant.Animation.EntranceOptions

	/**
	The option of the hide animation. Global change.
	*/
	public static var animationExitOptions = DPDConstant.Animation.ExitOptions

	/**
	The option of the show animation. Only change the caller. To change all drop down's use the static var.
	*/
	public var animationEntranceOptions: UIView.AnimationOptions = DropDown.animationEntranceOptions

	/**
	The option of the hide animation. Only change the caller. To change all drop down's use the static var.
	*/
	public var animationExitOptions: UIView.AnimationOptions = DropDown.animationExitOptions

	/**
	The downScale transformation of the tableview when the DropDown is appearing
	*/
	public var downScaleTransform = DPDConstant.Animation.DownScaleTransform {
		willSet { tableViewContainer.transform = newValue }
	}

	/**
	The color of the text for each cells of the drop down.

	Changing the text color automatically reloads the drop down.
	*/
    @objc public dynamic var textColor = DPDConstant.UI.TextColor {
		didSet { reloadAllComponents() }
	}

	/**
	The font of the text for each cells of the drop down.

	Changing the text font automatically reloads the drop down.
	*/
    @objc public dynamic var textFont = DPDConstant.UI.TextFont {
		didSet { reloadAllComponents() }
	}

    /**
     The NIB to use for DropDownCells

     Changing the cell nib automatically reloads the drop down.
     */
	public var cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self)) {
		didSet {
			tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropDownCell)
			templateCell = nil
			reloadAllComponents()
		}
	}

	// MARK: Content

	/**
	The data source for the drop down.

	Changing the data source automatically reloads the drop down.
	*/
	public var dataSource = [String]() {
		didSet {
			deselectRow(at: selectedRowIndex)
			reloadAllComponents()
		}
	}

	/**
	The localization keys for the data source for the drop down.

	Changing this value automatically reloads the drop down.
	This has uses for setting accibility identifiers on the drop down cells (same ones as the localization keys).
	*/
	public var localizationKeysDataSource = [String]() {
		didSet {
			dataSource = localizationKeysDataSource.map { NSLocalizedString($0, comment: "") }
		}
	}

	/// The index of the row after its seleciton.
	fileprivate var selectedRowIndex: Index?

	/**
	The format for the cells' text.

	By default, the cell's text takes the plain `dataSource` value.
	Changing `cellConfiguration` automatically reloads the drop down.
	*/
	public var cellConfiguration: ConfigurationClosure? {
		didSet { reloadAllComponents() }
	}

    /**
     A advanced formatter for the cells. Allows customization when custom cells are used

     Changing `customCellConfiguration` automatically reloads the drop down.
     */
    public var customCellConfiguration: CellConfigurationClosure? {
        didSet { reloadAllComponents() }
    }

	/// The action to execute when the user selects a cell.
	public var selectionAction: SelectionClosure?

	/// The action to execute when the drop down will show.
	public var willShowAction: Closure?

	/// The action to execute when the user cancels/hides the drop down.
	public var cancelAction: Closure?

	/// The dismiss mode of the drop down. Default is `OnTap`.
	public var dismissMode = DismissMode.onTap {
		willSet {
			if newValue == .onTap {
				let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
				dismissableView.addGestureRecognizer(gestureRecognizer)
			} else if let gestureRecognizer = dismissableView.gestureRecognizers?.first {
				dismissableView.removeGestureRecognizer(gestureRecognizer)
			}
		}
	}

	fileprivate var minHeight: CGFloat {
		return tableView.rowHeight
	}

	fileprivate var didSetupConstraints = false

	// MARK: - Init's

	deinit {
		stopListeningToNotifications()
	}

	/**
	Creates a new instance of a drop down.
	Don't forget to setup the `dataSource`,
	the `anchorView` and the `selectionAction`
	at least before calling `show()`.
	*/
	public convenience init() {
		self.init(frame: .zero)
	}

	/**
	Creates a new instance of a drop down.

	- parameter anchorView:        The view to which the drop down will displayed onto.
	- parameter selectionAction:   The action to execute when the user selects a cell.
	- parameter dataSource:        The data source for the drop down.
	- parameter topOffset:         The offset point relative to `anchorView` used when drop down is displayed on above the anchor view.
	- parameter bottomOffset:      The offset point relative to `anchorView` used when drop down is displayed on below the anchor view.
	- parameter cellConfiguration: The format for the cells' text.
	- parameter cancelAction:      The action to execute when the user cancels/hides the drop down.

	- returns: A new instance of a drop down customized with the above parameters.
	*/
	public convenience init(anchorView: AnchorView, selectionAction: SelectionClosure? = nil, dataSource: [String] = [], topOffset: CGPoint? = nil, bottomOffset: CGPoint? = nil, cellConfiguration: ConfigurationClosure? = nil, cancelAction: Closure? = nil) {
		self.init(frame: .zero)

		self.anchorView = anchorView
		self.selectionAction = selectionAction
		self.dataSource = dataSource
		self.topOffset = topOffset ?? .zero
		self.bottomOffset = bottomOffset ?? .zero
		self.cellConfiguration = cellConfiguration
		self.cancelAction = cancelAction
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

}

// MARK: - Setup

private extension DropDown {

	func setup() {
		tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropDownCell)

		DispatchQueue.main.async {
			//HACK: If not done in dispatch_async on main queue `setupUI` will have no effect
			self.updateConstraintsIfNeeded()
			self.setupUI()
		}

		dismissMode = .onTap

		tableView.delegate = self
		tableView.dataSource = self

		startListeningToKeyboard()

		accessibilityIdentifier = "drop_down"
	}

	func setupUI() {
		super.backgroundColor = .clear

		tableViewContainer.layer.masksToBounds = false
		tableViewContainer.layer.cornerRadius = cornerRadius
		tableViewContainer.layer.shadowColor = shadowColor.cgColor
		tableViewContainer.layer.shadowOffset = shadowOffset
		tableViewContainer.layer.shadowOpacity = shadowOpacity
		tableViewContainer.layer.shadowRadius = shadowRadius

		tableView.rowHeight = cellHeight
		tableView.backgroundColor = tableViewBackgroundColor
		tableView.separatorColor = separatorColor
		tableView.layer.cornerRadius = cornerRadius
		tableView.layer.masksToBounds = true

		setHiddentState()
		isHidden = true
	}

}

// MARK: - UI

extension DropDown {

	public override func updateConstraints() {
		if !didSetupConstraints {
			setupConstraints()
		}

		didSetupConstraints = true

		let layout = computeLayout()

		if !layout.canBeDisplayed {
			super.updateConstraints()
			hide()

			return
		}

		xConstraint.constant = layout.x
		yConstraint.constant = layout.y
		widthConstraint.constant = layout.width
		heightConstraint.constant = layout.visibleHeight

		tableView.isScrollEnabled = layout.offscreenHeight > 0

		DispatchQueue.main.async { [unowned self] in
			self.tableView.flashScrollIndicators()
		}

		super.updateConstraints()
	}

	fileprivate func setupConstraints() {
		translatesAutoresizingMaskIntoConstraints = false

		// Dismissable view
		addSubview(dismissableView)
		dismissableView.translatesAutoresizingMaskIntoConstraints = false

		addUniversalConstraints(format: "|[dismissableView]|", views: ["dismissableView": dismissableView])

		// Table view container
		addSubview(tableViewContainer)
		tableViewContainer.translatesAutoresizingMaskIntoConstraints = false

		xConstraint = NSLayoutConstraint(
			item: tableViewContainer,
			attribute: .leading,
			relatedBy: .equal,
			toItem: self,
			attribute: .leading,
			multiplier: 1,
			constant: 0)
		addConstraint(xConstraint)

		yConstraint = NSLayoutConstraint(
			item: tableViewContainer,
			attribute: .top,
			relatedBy: .equal,
			toItem: self,
			attribute: .top,
			multiplier: 1,
			constant: 0)
		addConstraint(yConstraint)

		widthConstraint = NSLayoutConstraint(
			item: tableViewContainer,
			attribute: .width,
			relatedBy: .equal,
			toItem: nil,
			attribute: .notAnAttribute,
			multiplier: 1,
			constant: 0)
		tableViewContainer.addConstraint(widthConstraint)

		heightConstraint = NSLayoutConstraint(
			item: tableViewContainer,
			attribute: .height,
			relatedBy: .equal,
			toItem: nil,
			attribute: .notAnAttribute,
			multiplier: 1,
			constant: 0)
		tableViewContainer.addConstraint(heightConstraint)

		// Table view
		tableViewContainer.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false

		tableViewContainer.addUniversalConstraints(format: "|[tableView]|", views: ["tableView": tableView])
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

		// When orientation changes, layoutSubviews is called
		// We update the constraint to update the position
		setNeedsUpdateConstraints()

		let shadowPath = UIBezierPath(roundedRect: tableViewContainer.bounds, cornerRadius: DPDConstant.UI.CornerRadius)
		tableViewContainer.layer.shadowPath = shadowPath.cgPath
	}

	fileprivate func computeLayout() -> (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat, visibleHeight: CGFloat, canBeDisplayed: Bool, Direction: Direction) {
		var layout: ComputeLayoutTuple = (0, 0, 0, 0)
		var direction = self.direction

		guard let window = UIWindow.visibleWindow() else { return (0, 0, 0, 0, 0, false, direction) }

		barButtonItemCondition: if let anchorView = anchorView as? UIBarButtonItem {
			let isRightBarButtonItem = anchorView.plainView.frame.minX > window.frame.midX

			guard isRightBarButtonItem else { break barButtonItemCondition }

			let width = self.width ?? fittingWidth()
			let anchorViewWidth = anchorView.plainView.frame.width
			let x = -(width - anchorViewWidth)

			bottomOffset = CGPoint(x: x, y: 0)
		}

		if anchorView == nil {
			layout = computeLayoutBottomDisplay(window: window)
			direction = .any
		} else {
			switch direction {
			case .any:
				layout = computeLayoutBottomDisplay(window: window)
				direction = .bottom

				if layout.offscreenHeight > 0 {
					let topLayout = computeLayoutForTopDisplay(window: window)

					if topLayout.offscreenHeight < layout.offscreenHeight {
						layout = topLayout
						direction = .top
					}
				}
			case .bottom:
				layout = computeLayoutBottomDisplay(window: window)
				direction = .bottom
			case .top:
				layout = computeLayoutForTopDisplay(window: window)
				direction = .top
			}
		}

		constraintWidthToFittingSizeIfNecessary(layout: &layout)
		constraintWidthToBoundsIfNecessary(layout: &layout, in: window)

		let visibleHeight = tableHeight - layout.offscreenHeight
		let canBeDisplayed = visibleHeight >= minHeight

		return (layout.x, layout.y, layout.width, layout.offscreenHeight, visibleHeight, canBeDisplayed, direction)
	}

	fileprivate func computeLayoutBottomDisplay(window: UIWindow) -> ComputeLayoutTuple {
		var offscreenHeight: CGFloat = 0

		let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - bottomOffset.x

		let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? window.frame.midX - (width / 2)
		let anchorViewY = anchorView?.plainView.windowFrame?.minY ?? window.frame.midY - (tableHeight / 2)

		let x = anchorViewX + bottomOffset.x
		let y = anchorViewY + bottomOffset.y

		let maxY = y + tableHeight
		let windowMaxY = window.bounds.maxY - DPDConstant.UI.HeightPadding

		let keyboardListener = KeyboardListener.sharedInstance
		let keyboardMinY = keyboardListener.keyboardFrame.minY - DPDConstant.UI.HeightPadding

		if keyboardListener.isVisible && maxY > keyboardMinY {
			offscreenHeight = abs(maxY - keyboardMinY)
		} else if maxY > windowMaxY {
			offscreenHeight = abs(maxY - windowMaxY)
		}

		return (x, y, width, offscreenHeight)
	}

	fileprivate func computeLayoutForTopDisplay(window: UIWindow) -> ComputeLayoutTuple {
		var offscreenHeight: CGFloat = 0

		let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? 0
		let anchorViewMaxY = anchorView?.plainView.windowFrame?.maxY ?? 0

		let x = anchorViewX + topOffset.x
		var y = (anchorViewMaxY + topOffset.y) - tableHeight

		let windowY = window.bounds.minY + DPDConstant.UI.HeightPadding

		if y < windowY {
			offscreenHeight = abs(y - windowY)
			y = windowY
		}

		let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - topOffset.x

		return (x, y, width, offscreenHeight)
	}

	fileprivate func fittingWidth() -> CGFloat {
		if templateCell == nil {
            templateCell = cellNib.instantiate(withOwner: nil, options: nil)[0] as? DropDownCell
		}

		var maxWidth: CGFloat = 0

		for index in 0..<dataSource.count {
			configureCell(templateCell, at: index)
			templateCell.bounds.size.height = cellHeight
			let width = templateCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width

			if width > maxWidth {
				maxWidth = width
			}
		}

		return maxWidth
	}

	fileprivate func constraintWidthToBoundsIfNecessary(layout: inout ComputeLayoutTuple, in window: UIWindow) {
		let windowMaxX = window.bounds.maxX
		let maxX = layout.x + layout.width

		if maxX > windowMaxX {
			let delta = maxX - windowMaxX
			let newOrigin = layout.x - delta

			if newOrigin > 0 {
				layout.x = newOrigin
			} else {
				layout.x = 0
				layout.width += newOrigin // newOrigin is negative, so this operation is a substraction
			}
		}
	}

	fileprivate func constraintWidthToFittingSizeIfNecessary(layout: inout ComputeLayoutTuple) {
		guard width == nil else { return }

		if layout.width < fittingWidth() {
			layout.width = fittingWidth()
		}
	}

}

// MARK: - Actions

extension DropDown {

    /**
     An Objective-C alias for the show() method which converts the returned tuple into an NSDictionary.

     - returns: An NSDictionary with a value for the "canBeDisplayed" Bool, and possibly for the "offScreenHeight" Optional(CGFloat).
     */
    @objc(show)
    public func objc_show() -> NSDictionary {
        let (canBeDisplayed, offScreenHeight) = show()

        var info = [AnyHashable: Any]()
        info["canBeDisplayed"] = canBeDisplayed
        if let offScreenHeight = offScreenHeight {
            info["offScreenHeight"] = offScreenHeight
        }

        return NSDictionary(dictionary: info)
    }

	/**
	Shows the drop down if enough height.

	- returns: Wether it succeed and how much height is needed to display all cells at once.
	*/
	@discardableResult
	public func show() -> (canBeDisplayed: Bool, offscreenHeight: CGFloat?) {
		if self == DropDown.VisibleDropDown {
			return (true, 0)
		}

		if let visibleDropDown = DropDown.VisibleDropDown {
			visibleDropDown.cancel()
		}

		willShowAction?()

		DropDown.VisibleDropDown = self

		setNeedsUpdateConstraints()

		let visibleWindow = UIWindow.visibleWindow()
		visibleWindow?.addSubview(self)
		visibleWindow?.bringSubviewToFront(self)

		self.translatesAutoresizingMaskIntoConstraints = false
		visibleWindow?.addUniversalConstraints(format: "|[dropDown]|", views: ["dropDown": self])

		let layout = computeLayout()

		if !layout.canBeDisplayed {
			hide()
			return (layout.canBeDisplayed, layout.offscreenHeight)
		}

		isHidden = false
		tableViewContainer.transform = downScaleTransform

		UIView.animate(
			withDuration: animationduration,
			delay: 0,
			options: animationEntranceOptions,
			animations: { [unowned self] in
				self.setShowedState()
			},
			completion: nil)

		selectRow(at: selectedRowIndex)

		return (layout.canBeDisplayed, layout.offscreenHeight)
	}

	/// Hides the drop down.
	public func hide() {
		if self == DropDown.VisibleDropDown {
			/*
			If one drop down is showed and another one is not
			but we call `hide()` on the hidden one:
			we don't want it to set the `VisibleDropDown` to nil.
			*/
			DropDown.VisibleDropDown = nil
		}

		if isHidden {
			return
		}

		UIView.animate(
			withDuration: animationduration,
			delay: 0,
			options: animationExitOptions,
			animations: { [unowned self] in
				self.setHiddentState()
			},
			completion: { [unowned self] _ in
				self.isHidden = true
				self.removeFromSuperview()
			})
	}

	fileprivate func cancel() {
		hide()
		cancelAction?()
	}

	fileprivate func setHiddentState() {
		alpha = 0
	}

	fileprivate func setShowedState() {
		alpha = 1
		tableViewContainer.transform = CGAffineTransform.identity
	}

}

// MARK: - UITableView

extension DropDown {

	/**
	Reloads all the cells.

	It should not be necessary in most cases because each change to
	`dataSource`, `textColor`, `textFont`, `selectionBackgroundColor`
	and `cellConfiguration` implicitly calls `reloadAllComponents()`.
	*/
	public func reloadAllComponents() {
		tableView.reloadData()
		setNeedsUpdateConstraints()
	}

	/// (Pre)selects a row at a certain index.
	public func selectRow(at index: Index?) {
		if let index = index {
			tableView.selectRow(
				at: IndexPath(row: index, section: 0),
				animated: false,
				scrollPosition: .middle)
		} else {
			deselectRow(at: selectedRowIndex)
		}

		selectedRowIndex = index
	}

	public func deselectRow(at index: Index?) {
		selectedRowIndex = nil

		guard let index = index, index >= 0
			else { return }

		tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
	}

	/// Returns the index of the selected row.
	public var indexForSelectedRow: Index? {
		return (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
	}

	/// Returns the selected item.
	public var selectedItem: String? {
		guard let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row else { return nil }

		return dataSource[row]
	}

	/// Returns the height needed to display all cells.
	fileprivate var tableHeight: CGFloat {
		return tableView.rowHeight * CGFloat(dataSource.count)
	}

}

// MARK: - UITableViewDataSource - UITableViewDelegate

extension DropDown: UITableViewDataSource, UITableViewDelegate {

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DPDConstant.ReusableIdentifier.DropDownCell, for: indexPath) as! DropDownCell
		let index = (indexPath as NSIndexPath).row

		configureCell(cell, at: index)

		return cell
	}

	fileprivate func configureCell(_ cell: DropDownCell, at index: Int) {
		if index >= 0 && index < localizationKeysDataSource.count {
			cell.accessibilityIdentifier = localizationKeysDataSource[index]
		}

		cell.optionLabel.textColor = textColor
		cell.optionLabel.font = textFont
		cell.selectedBackgroundColor = selectionBackgroundColor

		if let cellConfiguration = cellConfiguration {
			cell.optionLabel.text = cellConfiguration(index, dataSource[index])
		} else {
			cell.optionLabel.text = dataSource[index]
		}

		customCellConfiguration?(index, dataSource[index], cell)
	}

	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.isSelected = (indexPath as NSIndexPath).row == selectedRowIndex
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedRowIndex = (indexPath as NSIndexPath).row
		selectionAction?(selectedRowIndex!, dataSource[selectedRowIndex!])

		if let _ = anchorView as? UIBarButtonItem {
			// DropDown's from UIBarButtonItem are menus so we deselect the selected menu right after selection
            deselectRow(at: selectedRowIndex)
		}

		hide()
	}

}

// MARK: - Auto dismiss

extension DropDown {

	public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let view = super.hitTest(point, with: event)

		if dismissMode == .automatic && view === dismissableView {
			cancel()
			return nil
		} else {
			return view
		}
	}

	@objc
	fileprivate func dismissableViewTapped() {
		cancel()
	}

}

// MARK: - Keyboard events

extension DropDown {

	/**
	Starts listening to keyboard events.
	Allows the drop down to display correctly when keyboard is showed.
	*/
	public static func startListeningToKeyboard() {
		KeyboardListener.sharedInstance.startListeningToKeyboard()
	}

	fileprivate func startListeningToKeyboard() {
		KeyboardListener.sharedInstance.startListeningToKeyboard()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardUpdate),
			name: UIResponder.keyboardWillShowNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardUpdate),
			name: UIResponder.keyboardWillHideNotification,
			object: nil)
	}

	fileprivate func stopListeningToNotifications() {
		NotificationCenter.default.removeObserver(self)
	}

	@objc
	fileprivate func keyboardUpdate() {
		self.setNeedsUpdateConstraints()
	}

}
