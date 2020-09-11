//
//  ActionCALayer.swift
//  ADD
//
//  Created by Ryan Francesconi on 2/12/19.
//  Copyright © 2019 Audio Design Desk. All rights reserved.
//

import Cocoa

public class ActionCALayer: CALayer {
    public var allowActions: Bool = false

    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }
}

public class ActionCAShapeLayer: CAShapeLayer {
    public var allowActions: Bool = false

    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }
}

public class ActionCATextLayer: CATextLayer {
    public var allowActions: Bool = false

    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }
}
