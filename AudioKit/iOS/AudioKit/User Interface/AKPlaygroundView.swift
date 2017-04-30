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

    open var elementHeight: CGFloat = 30
    open var xInset: Int = 30
    open var yPosition: Int = 25
    open var spacing = 25

    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = .white
        setup()
    }

    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: 1_000))
    }

    open func setup() {}

    open func addTitle(_ text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .center
        newLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.addSubview(newLabel)

        return newLabel
    }

    open func addLabel(_ text: String) -> UILabel {
        let newLabel = UILabel(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(newLabel)

        return newLabel
    }

    open override func addSubview(_ potentialView: UIView?) {
        guard let view = potentialView else {
            return
        }
        view.frame.origin.y = CGFloat(yPosition)
        if view.frame.origin.x < CGFloat(xInset) {
            view.frame.origin.x = CGFloat(xInset)
        }
        super.addSubview(view)
        yPosition += Int(view.frame.height) + spacing

        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(yPosition))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
