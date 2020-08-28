// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)
import UIKit

public typealias Label = UILabel

/// UIView for playgrounds allowing live views to be generated easily
public class AKPlaygroundView: UIView {

    /// Default standard element height (buttons, text)
    open var elementHeight: CGFloat = 30

    /// Current Y position
    open var yPosition: Int = 25

    /// Spacing height between elements
    open var spacing = 25

    /// Initialize the playground view
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = AKStylist.sharedInstance.bgColor
        setup()
    }

    /// Initialize with default size
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: 1_000))
    }

    /// Override this function in subclasses
    public func setup() {}

    /// Add a title to the playground view
    public func addTitle(_ text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.textAlignment = .center
        newLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.addSubview(newLabel)

        return newLabel
    }

    /// Add label text
    public func addLabel(_ text: String) -> UILabel {
        let newLabel = UILabel(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(newLabel)

        return newLabel
    }

    /// Add the subview, and move the Y Position down
    public override func addSubview(_ potentialView: UIView?) {
        guard let view = potentialView else {
            AKLog("Unable to create view in addSubview")
            return
        }
        view.frame.origin.y = CGFloat(yPosition)
        if view.frame.origin.x < 30 {
            view.frame.origin.x = 30
        }
        super.addSubview(view)
        yPosition += Int(view.frame.height) + spacing

        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(yPosition))
    }

    /// Initialization within Interface Builder
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#else

import Cocoa

public typealias Label = AKLabel

public class AKLabel: NSTextField {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var text: String = "" {
        didSet {
            stringValue = text
        }
    }
}

public class AKPlaygroundView: NSView {

    public var elementHeight: CGFloat = 30
    public var spacing = 25
    private var potentialSubviews = [NSView]()

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: 1_000))
    }

    public func setup() {}

    override public func draw(_ dirtyRect: NSRect) {
        let backgroundColor = AKStylist.sharedInstance.bgColor
        backgroundColor.setFill()
        __NSRectFill(dirtyRect)
        super.draw(dirtyRect)
    }

    public func addTitle(_ text: String) -> NSTextField {
        let newLabel = NSTextField(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.alignment = .center
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = NSFont.boldSystemFont(ofSize: 24)
        self.addSubview(newLabel)
        return newLabel
    }

    public func addLabel(_ text: String) -> AKLabel {
        let newLabel = AKLabel(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width, height: elementHeight))
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = NSFont.systemFont(ofSize: 18)
        self.addSubview(newLabel)
        return newLabel
    }

    public override func addSubview(_ subview: NSView?) {
        guard let view = subview else {
            return
        }
        subviews.removeAll()
        potentialSubviews.append(view)
        let reversedSubviews = potentialSubviews.reversed()
        var yPosition = spacing
        for view in reversedSubviews {
            if view.frame.origin.x < 30 {
                view.frame.origin.x = 30
            }
            view.frame.origin.y = CGFloat(yPosition)
            yPosition += Int(view.frame.height) + spacing
            super.addSubview(view)
        }
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(yPosition))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
