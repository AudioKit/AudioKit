//
//  MenuButton.swift
//
//  Created by Ryan Francesconi on 8/3/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import Cocoa

/// A custom popup button that you can fill with submenus
@IBDesignable
class MenuButton: NSButton {
    @IBInspectable var bgColor: NSColor?
    @IBInspectable var textColor: NSColor?

    override func awakeFromNib() {
        if let textColor = textColor, let font = font {
            let style = NSMutableParagraphStyle()
            style.alignment = .center

            let attributes: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.foregroundColor: textColor,
                    NSAttributedStringKey.font: font,
                    NSAttributedStringKey.paragraphStyle: style]

            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            self.attributedTitle = attributedTitle
            initialize()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        if let bgColor = bgColor {
            bgColor.setFill()
            let rect = NSMakeRect(0, 0, bounds.width, bounds.height)
            let rectanglePath = NSBezierPath( roundedRect: rect, xRadius: 3, yRadius: 3)
            rectanglePath.fill()
        }
        super.draw(dirtyRect)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
        initialize()
    }

    private func initialize() {
        if let cell = self.cell as? NSButtonCell {
            cell.isBordered = false //The background color is used only when drawing borderless buttons.
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        // kill this so the menu doesn't show at this down location
    }

    override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        guard menu != nil else { return }
        guard superview != nil else { return }

        var adjustedLocation = convert(NSPoint(), to: nil)
        adjustedLocation.y -= (self.frame.size.height + 5)

        if let newEvent = NSEvent.mouseEvent(with: event.type,
                                             location: adjustedLocation,
                                             modifierFlags: event.modifierFlags,
                                             timestamp: event.timestamp,
                                             windowNumber: event.windowNumber,
                                             context: event.context,
                                             eventNumber: event.eventNumber + 1,
                                             clickCount: 1,
                                             pressure: 0) {

            menu!.autoenablesItems = false
            NSMenu.popUpContextMenu(menu!, with: newEvent, for: self)
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

    }
}
