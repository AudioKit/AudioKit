//
//  AKLiveViewController.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 9/22/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public typealias AKLabel = UILabel

open class AKLiveViewController: UIViewController {

    var stackView: UIStackView!

    override open func loadView() {
        stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view = stackView
    }

    public func addTitle(_ text: String) {
        let newLabel = UILabel()
        newLabel.text = text
        newLabel.textAlignment = .center
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = UIFont.boldSystemFont(ofSize: 24)
        newLabel.sizeThatFits(CGSize(width:400, height: 80))
        newLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addView(newLabel)
    }

    public func addLabel(_ text: String) -> AKLabel {
        let newLabel = AKLabel(frame: CGRect(x: 0, y: 0, width:400, height: 80))
        newLabel.text = text
        newLabel.textColor = AKStylist.sharedInstance.fontColor
        newLabel.font = UIFont.systemFont(ofSize: 18)
        newLabel.sizeThatFits(CGSize(width:400, height: 40))
        newLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addView(newLabel)
        return newLabel
    }

    public func addView(_ newView: UIView) {
        newView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        if newView.frame.height <= 60 {
            newView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        } else {
            newView.heightAnchor.constraint(equalToConstant: newView.frame.height).isActive = true
        }
        stackView.addArrangedSubview(newView)
        stackView.sizeThatFits(CGSize(width: stackView.frame.width,
                                      height: stackView.frame.height + newView.frame.height))
    }
}
