//
//  SMBasicSegmentView.swift
//  SMSegmentViewController
//
//  Created by mlaskowski on 01/10/15.
//  Copyright © 2016 si.ma. All rights reserved.
//

import Foundation
import UIKit

public enum SegmentOrganiseMode: Int {
    case segmentOrganiseHorizontal = 0
    case segmentOrganiseVertical
}

public protocol SMSegmentViewDelegate: class {
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int)
}

open class SMBasicSegmentView: UIView {
    open var segments: [SMBasicSegment] = [] {
        didSet {
            var i = 0
            for segment in segments {
                segment.index = i
                i += 1
                segment.segmentView = self
                self.addSubview(segment)
            }
            self.updateFrameForSegments()

        }
    }
    open weak var delegate: SMSegmentViewDelegate?

    open fileprivate(set) var indexOfSelectedSegment: Int = NSNotFound
    var numberOfSegments: Int {
        return segments.count
    }

    @IBInspectable open var vertical: Bool = false {
        didSet {
            let mode = vertical ? SegmentOrganiseMode.segmentOrganiseVertical : SegmentOrganiseMode.segmentOrganiseHorizontal
            self.orientationChangedTo(mode)
        }
    }

    // Segment Separator
    @IBInspectable open var separatorColour: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable open var separatorWidth: CGFloat = 1.0 {
        didSet {
            self.updateFrameForSegments()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.updateFrameForSegments()
    }

    open func orientationChangedTo(_ mode: SegmentOrganiseMode) {
        for segment in self.segments {
            segment.orientationChangedTo(mode)
        }
        setNeedsDisplay()
    }

    open func updateFrameForSegments() {
        if self.segments.isEmpty {
            return
        }

        let count = self.segments.count
        if count > 1 {
            if self.vertical == false {
                let segmentWidth = (self.frame.size.width - self.separatorWidth * CGFloat(count - 1)) / CGFloat(count)
                var originX: CGFloat = 0.0
                for segment in self.segments {
                    segment.frame = CGRect(x: originX, y: 0.0, width: segmentWidth, height: self.frame.size.height)
                    originX += segmentWidth + self.separatorWidth
                }
            } else {
                let segmentHeight = (self.frame.size.height - self.separatorWidth * CGFloat(count - 1)) / CGFloat(count)
                var originY: CGFloat = 0.0
                for segment in self.segments {
                    segment.frame = CGRect(x: 0.0, y: originY, width: self.frame.size.width, height: segmentHeight)
                    originY += segmentHeight + self.separatorWidth
                }
            }
        } else {
            self.segments[0].frame = CGRect(x: 0.0,
                                            y: 0.0,
                                            width: self.frame.size.width,
                                            height: self.frame.size.height)
        }

        self.setNeedsDisplay()
    }

    open func drawSeparatorWithContext(_ context: CGContext) {
        context.saveGState()

        if self.segments.count > 1 {
            let path = CGMutablePath()

            if self.vertical == false {
                var originX: CGFloat = self.segments[0].frame.size.width + self.separatorWidth / 2.0
                for index in 1..<self.segments.count {
//                    CGPathMoveToPoint(path, nil, originX, 0.0)
//                    CGPathAddLineToPoint(path, nil, originX, self.frame.size.height)

                    originX += self.segments[index].frame.width + self.separatorWidth
                }
            } else {
                var originY: CGFloat = self.segments[0].frame.size.height + self.separatorWidth / 2.0
                for index in 1..<self.segments.count {
//                    CGPathMoveToPoint(path, nil, 0.0, originY)
//                    CGPathAddLineToPoint(path, nil, self.frame.size.width, originY)

                    originY += self.segments[index].frame.height + self.separatorWidth
                }
            }

            context.addPath(path)
            context.setStrokeColor(self.separatorColour.cgColor)
            context.setLineWidth(self.separatorWidth)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }

        context.restoreGState()
    }

    // MARK: Drawing Segment Separators
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        self.drawSeparatorWithContext(context)
    }

    // MARK: Actions
    open func selectSegmentAtIndex(_ index: Int) {
        assert(index >= 0 && index < self.segments.count, "Index at \(index) is out of bounds")

        if self.indexOfSelectedSegment != NSNotFound {
            let previousSelectedSegment = self.segments[self.indexOfSelectedSegment]
            previousSelectedSegment.setSelected(false, inView: self)
        }
        self.indexOfSelectedSegment = index
        let segment = self.segments[index]
        segment.setSelected(true, inView: self)
        self.delegate?.segmentView(self, didSelectSegmentAtIndex: index)
    }

    open func deselectSegment() {
        if self.indexOfSelectedSegment != NSNotFound {
            let segment = self.segments[self.indexOfSelectedSegment]
            segment.setSelected(false, inView: self)
            self.indexOfSelectedSegment = NSNotFound
        }
    }

    open func addSegment(_ segment: SMBasicSegment) {
        segment.index = self.segments.count
        self.segments.append(segment)

        segment.segmentView = self
        self.updateFrameForSegments()
        self.addSubview(segment)

    }

}
