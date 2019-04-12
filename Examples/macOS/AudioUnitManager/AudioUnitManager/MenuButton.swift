//
//  MenuButton.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//

import Cocoa

@IBDesignable
class MenuButton: NSButton {
    @IBInspectable var bgColor: NSColor?
    @IBInspectable var textColor: NSColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        if let textColor = textColor, let font = font {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: textColor,
                                                             NSAttributedString.Key.font: font,
                                                             NSAttributedString.Key.paragraphStyle: style]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            self.attributedTitle = attributedTitle
            initialize()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        if let bgColor = bgColor {
            bgColor.setFill()
            let rect = NSRect(origin: CGPoint(), size: bounds.size)
            let rectanglePath = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
            rectanglePath.fill()
        }
        super.draw(dirtyRect)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        if let cell = self.cell as? NSButtonCell {
            cell.isBordered = false // The background color is used only when drawing borderless buttons.
            // cell.backgroundColor = bgColor //NSColor.gray.withAlphaComponent(0.5)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        // kill this
    }

    override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        guard let menu = menu else { return }

        var adjustedLocation = convert(NSPoint(), to: nil)
        adjustedLocation.y -= (frame.size.height + 5)
        if let newEvent = NSEvent.mouseEvent(with: event.type,
                                             location: adjustedLocation,
                                             modifierFlags: event.modifierFlags,
                                             timestamp: event.timestamp,
                                             windowNumber: event.windowNumber,
                                             context: nil,
                                             eventNumber: event.eventNumber + 1,
                                             clickCount: 1,
                                             pressure: 0) {
            menu.autoenablesItems = false
            NSMenu.popUpContextMenu(menu, with: newEvent, for: self)
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
    }
}
