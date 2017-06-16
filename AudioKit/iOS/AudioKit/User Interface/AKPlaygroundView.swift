//
//  AKPlaygroundView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import UIKit
public typealias Label = UILabel

open class AKPlaygroundView: UIView {

    /// Default standard element height (buttons, text)
    open var elementHeight: CGFloat = 30
    
    /// Current Y position
    open var yPosition: Int = 25
    
    /// Spacing height between elements
    open var spacing = 25

    /// Initialize the playground view
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = .white
        setup()
    }

    /// Initialize with default size
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: 1_000))
    }

    /// Override this function in subclasses
    open func setup() {}

    /// Add a title to the playground view
    open func addTitle(_ text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .center
        newLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.addSubview(newLabel)

        return newLabel
    }

    /// Add label text
    open func addLabel(_ text: String) -> UILabel {
        let newLabel = UILabel(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(newLabel)

        return newLabel
    }

    /// Add the subview, and move the Y Position down
    open override func addSubview(_ potentialView: UIView?) {
        guard let view = potentialView else {
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
