//
//  AKPlaygroundViewController.swift
//  AudioKit For macOS
//
//  Created by Aurelius Prochazka on 8/20/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa

public class AKLiveViewController: NSViewController {
    var stackView: NSStackView!
    var textField: NSTextField?

    override public func loadView() {
        stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 400, height: 120))
        stackView.alignment = .centerX
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        setup()
        addTitle(title ?? "untitled")

        self.view = stackView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func setup() {
        // Override in subclass
    }

    public func addTitle(_ text: String) {
        let newLabel = NSTextField()
        newLabel.stringValue = text
        newLabel.isEditable = false
        newLabel.drawsBackground = false
        newLabel.isBezeled = false
        newLabel.alignment = .center
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = NSFont.boldSystemFont(ofSize: 24)
        stackView.insertView(newLabel, at: 0, in: .top)
    }

    public func addPlaygroundView(_ newView: NSView) {
        newView.widthAnchor.constraint(equalToConstant: 400).isActive = true

        newView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        stackView?.addArrangedSubview(newView)
        stackView.setFrameSize(NSSize(width: stackView.frame.width, height: stackView.frame.height + newView.frame.height))
    }
}
