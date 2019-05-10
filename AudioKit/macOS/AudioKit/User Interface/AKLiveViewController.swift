//
//  AKLiveViewController.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

public typealias AKLabel = NSTextField

open class AKLiveViewController: NSViewController {

    var stackView: NSStackView!
    var textField: NSTextField?

    override open func loadView() {
        stackView = NSStackView(frame: NSRect(width: 400, height: 100))
        stackView.alignment = .centerX
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layer?.backgroundColor = NSColor.black.cgColor
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
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = .boldSystemFont(ofSize: 24)
        newLabel.setFrameSize(NSSize(width: 400, height: 40))
        newLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addView(newLabel)
    }

    public func addLabel(_ text: String) -> AKLabel {
        let newLabel = AKLabel(frame: NSRect(width: 400, height: 80))
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = .systemFont(ofSize: 18)
        newLabel.setFrameSize(NSSize(width: 400, height: 40))
        newLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
