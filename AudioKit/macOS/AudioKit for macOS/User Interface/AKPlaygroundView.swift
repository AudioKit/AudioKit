//
//  AKPlaygroundView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/31/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

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

open class AKPlaygroundView: NSView {

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

    open func setup() {}

    override open func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        super.draw(dirtyRect)
    }

    public func addTitle(_ text: String) -> NSTextField {
        let newLabel = NSTextField(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.alignment = NSCenterTextAlignment
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
        newLabel.font = NSFont.systemFont(ofSize: 18)
        self.addSubview(newLabel)
        return newLabel
    }

    open override func addSubview(_ view: NSView) {
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
