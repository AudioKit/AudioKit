//
//  SMSegmentView.swift
//
//  Created by Si MA on 03/01/2016.
//  Copyright (c) 2016 Si Ma. All rights reserved.
//

import UIKit
// swiftlint:disable force_cast

/*
  Keys for segment properties
*/

// This is mainly for the top/bottom margin of the imageView
let keyContentVerticalMargin = "VerticalMargin"

// The colour when the segment is under selected/unselected
let keySegmentOnSelectionColour = "OnSelectionBackgroundColour"
let keySegmentOffSelectionColour = "OffSelectionBackgroundColour"

// The colour of the text in the segment for the segment is under selected/unselected
let keySegmentOnSelectionTextColour = "OnSelectionTextColour"
let keySegmentOffSelectionTextColour = "OffSelectionTextColour"

// The font of the text in the segment
let keySegmentTitleFont = "TitleFont"

@IBDesignable
open class SMSegmentView: SMBasicSegmentView {

    @IBInspectable open var segmentVerticalMargin: CGFloat = 5.0 {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.verticalMargin = self.segmentVerticalMargin
            }
        }
    }

    // Segment Colour
    @IBInspectable open var segmentOnSelectionColour: UIColor = UIColor.darkGray {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.onSelectionColour = self.segmentOnSelectionColour
            }
        }
    }
    @IBInspectable open var segmentOffSelectionColour: UIColor = UIColor.white {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.offSelectionColour = self.segmentOffSelectionColour
            }
        }
    }

    // Segment Title Text Colour & Font
    @IBInspectable open var segmentOnSelectionTextColour: UIColor = UIColor.white {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.onSelectionTextColour = self.segmentOnSelectionTextColour
            }
        }
    }
    @IBInspectable open var segmentOffSelectionTextColour: UIColor = UIColor.darkGray {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.offSelectionTextColour = self.segmentOffSelectionTextColour
            }
        }
    }
    open var segmentTitleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.titleFont = self.segmentTitleFont
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }

    public init(frame: CGRect,
                separatorColour: UIColor,
                separatorWidth: CGFloat,
                segmentProperties: [String: AnyObject]?) {

        super.init(frame: frame)

        self.separatorColour = separatorColour
        self.separatorWidth = separatorWidth

        if let margin = segmentProperties?[keyContentVerticalMargin] as? Float {
            self.segmentVerticalMargin = CGFloat(margin)
        }

        if let onSelectionColour = segmentProperties?[keySegmentOnSelectionColour] as? UIColor {
            self.segmentOnSelectionColour = onSelectionColour
        } else {
            self.segmentOnSelectionColour = UIColor.darkGray
        }

        if let offSelectionColour = segmentProperties?[keySegmentOffSelectionColour] as? UIColor {
            self.segmentOffSelectionColour = offSelectionColour
        } else {
            self.segmentOffSelectionColour = UIColor.white
        }

        if let onSelectionTextColour = segmentProperties?[keySegmentOnSelectionTextColour] as? UIColor {
            self.segmentOnSelectionTextColour = onSelectionTextColour
        } else {
            self.segmentOnSelectionTextColour = UIColor.white
        }

        if let offSelectionTextColour = segmentProperties?[keySegmentOffSelectionTextColour] as? UIColor {
            self.segmentOffSelectionTextColour = offSelectionTextColour
        } else {
            self.segmentOffSelectionTextColour = UIColor.darkGray
        }

        if let titleFont = segmentProperties?[keySegmentTitleFont] as? UIFont {
            self.segmentTitleFont = titleFont
        } else {
            self.segmentTitleFont = UIFont.systemFont(ofSize: 17.0)
        }

        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }

    open func addSegmentWithTitle(_ title: String?,
                                  onSelectionImage: UIImage?,
                                  offSelectionImage: UIImage?) -> SMSegment {

        let segment = SMSegment(verticalMargin: self.segmentVerticalMargin,
                                onSelectionColour: self.segmentOnSelectionColour,
                                offSelectionColour: self.segmentOffSelectionColour,
                                onSelectionTextColour: self.segmentOnSelectionTextColour,
                                offSelectionTextColour: self.segmentOffSelectionTextColour,
                                titleFont: self.segmentTitleFont)

        segment.title = title
        segment.onSelectionImage = onSelectionImage
        segment.offSelectionImage = offSelectionImage

        super.addSegment(segment)

        return segment
    }

}
