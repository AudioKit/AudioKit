//
//  VerticalSliderStyles.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/11/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.

import UIKit

public class VerticalSliderStyles: NSObject {

    //// Drawing Methods

    public class func drawVerticalSlider(controlFrame controlFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 216), knobRect: CGRect = CGRect(x: 0, y: 89, width: 36, height: 32)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()


        //// Image Declarations
        let slider_top = UIImage(named: "slider_top.png")!
        let slider_track = UIImage(named: "slider_track.png")!

        //// Background Drawing
        let backgroundRect = CGRectMake(controlFrame.minX + 2, controlFrame.minY + 10, 38, 144)
        let backgroundPath = UIBezierPath(rect: backgroundRect)
        CGContextSaveGState(context)
        backgroundPath.addClip()
        slider_track.drawInRect(CGRectMake(floor(backgroundRect.minX + 0.5), floor(backgroundRect.minY + 0.5), slider_track.size.width, slider_track.size.height))
        CGContextRestoreGState(context)


        //// Slider Top Drawing
        let sliderTopRect = CGRectMake(knobRect.origin.x, knobRect.origin.y, knobRect.size.width, knobRect.size.height)
        let sliderTopPath = UIBezierPath(rect: sliderTopRect)
        CGContextSaveGState(context)
        sliderTopPath.addClip()
        slider_top.drawInRect(CGRectMake(floor(sliderTopRect.minX + 0.5), floor(sliderTopRect.minY + 0.5), slider_top.size.width, slider_top.size.height))
        CGContextRestoreGState(context)
    }

}
