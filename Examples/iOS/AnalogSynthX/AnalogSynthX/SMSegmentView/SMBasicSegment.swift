//
//  SMBasicSegment.swift
//  SMSegmentViewController
//
//  Created by mlaskowski on 01/10/15.
//  Copyright © 2016 si.ma. All rights reserved.
//

import Foundation
import UIKit

open class SMBasicSegment: UIView {
    open internal(set) var index: Int = 0
    open internal(set) weak var segmentView: SMBasicSegmentView?

    open fileprivate(set) var isSelected: Bool = false

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: Selections
    internal func setSelected(_ selected: Bool, inView view: SMBasicSegmentView) {
        self.isSelected = selected
    }

    open func orientationChangedTo(_ mode: SegmentOrganiseMode) {

    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.isSelected == false {
            self.segmentView?.selectSegmentAtIndex(self.index)
        }
    }
}
