//
//  AKPresetLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

public class AKPresetLoaderView: UIView {
    
    var player: AKAudioPlayer?
    var presetOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()
    
    var currentIndex = 0
    var presets = [String]()
    var callback: String -> ()
    var isPresetLoaded = false
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            isPresetLoaded = false
            let touchLocation = touch.locationInView(self)
            if upOuterPath.containsPoint(touchLocation) {
                currentIndex -= 1
                isPresetLoaded = true
            }
            if downOuterPath.containsPoint(touchLocation) {
                currentIndex += 1
                isPresetLoaded = true
            }
            if currentIndex < 0 { currentIndex = presets.count - 1 }
            if currentIndex >= presets.count { currentIndex = 0 }
            
            if isPresetLoaded {
                callback(presets[currentIndex])
                setNeedsDisplay()
            }
        }
    }
    
    public init(presets: [String], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60), callback: String -> ()) {
        self.callback = callback
        self.presets = presets
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPresetLoader(presetName presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let red = UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let gray = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let green = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)
        let dark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Variable Declarations
        let expression = isPresetLoaded ? green : red
        
        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        gray.setFill()
        backgroundPath.fill()
        
        
        //// presetButton
        //// presetOuter Drawing
        presetOuterPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 95, height: 60))
        expression.setFill()
        presetOuterPath.fill()
        
        
        //// presetLabel Drawing
        let presetLabelRect = CGRect(x: 0, y: 0, width: 95, height: 60)
        let presetLabelTextContent = NSString(string: "Preset")
        let presetLabelStyle = NSMutableParagraphStyle()
        presetLabelStyle.alignment = .Left
        
        let presetLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: presetLabelStyle]
        
        let presetLabelInset: CGRect = CGRectInset(presetLabelRect, 10, 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRectWithSize(CGSize(width: presetLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: presetLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, presetLabelInset)
        presetLabelTextContent.drawInRect(CGRect(x: presetLabelInset.minX, y: presetLabelInset.minY + (presetLabelInset.height - presetLabelTextHeight) / 2, width: presetLabelInset.width, height: presetLabelTextHeight), withAttributes: presetLabelFontAttributes)
        CGContextRestoreGState(context)
        
        
        
        
        //// upButton
        //// upOuter Drawing
        upOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 0, width: 59, height: 30))
        gray.setFill()
        upOuterPath.fill()
        
        
        //// upInner Drawing
        let upInnerPath = UIBezierPath()
        upInnerPath.moveToPoint(CGPoint(x: 395.75, y: 22.5))
        upInnerPath.addLineToPoint(CGPoint(x: 425.25, y: 22.5))
        upInnerPath.addLineToPoint(CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLineToPoint(CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLineToPoint(CGPoint(x: 395.75, y: 22.5))
        upInnerPath.closePath()
        dark.setFill()
        upInnerPath.fill()
        
        
        
        
        //// downButton
        //// downOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 30, width: 59, height: 30))
        gray.setFill()
        downOuterPath.fill()
        
        
        //// downInner Drawing
        let downInnerPath = UIBezierPath()
        downInnerPath.moveToPoint(CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLineToPoint(CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLineToPoint(CGPoint(x: 425.25, y: 37.5))
        downInnerPath.addLineToPoint(CGPoint(x: 395.75, y: 37.5))
        downInnerPath.addLineToPoint(CGPoint(x: 410.5, y: 52.5))
        downInnerPath.closePath()
        dark.setFill()
        downInnerPath.fill()
        
        
        
        
        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 95, y: 0, width: 345, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .Left
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = CGRectInset(nameLabelRect, 10, 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRectWithSize(CGSize(width: nameLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nameLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, nameLabelInset)
        NSString(string: presetName).drawInRect(CGRect(x: nameLabelInset.minX, y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, width: nameLabelInset.width, height: nameLabelTextHeight), withAttributes: nameLabelFontAttributes)
        CGContextRestoreGState(context)
    }
    
    override public func drawRect(rect: CGRect) {
        let presetName = isPresetLoaded ? presets[currentIndex] : "None"
        drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
    }
}
