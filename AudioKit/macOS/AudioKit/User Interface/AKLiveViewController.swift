//
//  AKLiveViewController.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 9/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa

public typealias AKLabel = NSTextField

open class AKLiveViewController: NSViewController {

    var stackView: NSStackView!
    var textField: NSTextField?

    override open func loadView() {
        stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        stackView.alignment = .centerX
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view = stackView
    }

    public func addTitle(_ text: String) {
        let newLabel = NSTextField()
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.alignment = .center
        newLabel.backgroundColor = NSColor.blue
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = NSFont.boldSystemFont(ofSize: 24)
        newLabel.setFrameSize(NSSize(width:400, height: 80))
        newLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addView(newLabel)
    }

    public func addLabel(_ text: String) -> AKLabel {
        let newLabel = AKLabel(frame: CGRect(x: 0, y: 0, width:400, height: 80))
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = NSFont.systemFont(ofSize: 18)
        newLabel.setFrameSize(NSSize(width:400, height: 40))
        newLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addView(newLabel)
        return newLabel
    }

    public func addView(_ newView: NSView) {
        newView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        if newView.frame.height <= 60 {
            newView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        } else {
            newView.heightAnchor.constraint(equalToConstant: newView.frame.height).isActive = true
        }
        stackView.addArrangedSubview(newView)
        stackView.setFrameSize(NSSize(width: stackView.frame.width,
                                      height: stackView.frame.height + newView.frame.height))
    }
}
