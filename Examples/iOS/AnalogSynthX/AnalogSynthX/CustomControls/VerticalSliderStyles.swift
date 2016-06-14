//
//  VerticalSliderStyles.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/11/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.

import UIKit

public class VerticalSliderStyles: NSObject {

    //// Drawing Methods

    public class func drawVerticalSlider(controlFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 216), knobRect: CGRect = CGRect(x: 0, y: 89, width: 36, height: 32)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()


        //// Image Declarations
        let slider_top = UIImage(named: "slider_top.png")!
        let slider_track = UIImage(named: "slider_track.png")!

        //// Background Drawing
        let backgroundRect = CGRect(x: controlFrame.minX + 2, y: controlFrame.minY + 10, width: 38, height: 144)
        let backgroundPath = UIBezierPath(rect: backgroundRect)
        context?.saveGState()
        backgroundPath.addClip()
        slider_track.draw(in: CGRect(x: floor(backgroundRect.minX + 0.5), y: floor(backgroundRect.minY + 0.5), width: slider_track.size.width, height: slider_track.size.height))
        context?.restoreGState()


        //// Slider Top Drawing
        let sliderTopRect = CGRect(x: knobRect.origin.x, y: knobRect.origin.y, width: knobRect.size.width, height: knobRect.size.height)
        let sliderTopPath = UIBezierPath(rect: sliderTopRect)
        context?.saveGState()
        sliderTopPath.addClip()
        slider_top.draw(in: CGRect(x: floor(sliderTopRect.minX + 0.5), y: floor(sliderTopRect.minY + 0.5), width: slider_top.size.width, height: slider_top.size.height))
        context?.restoreGState()
    }

}
