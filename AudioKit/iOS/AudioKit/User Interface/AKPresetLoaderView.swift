//
//  AKPresetLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

open class AKPresetLoaderView: UIView {
    
    var player: AKAudioPlayer?
    var presetOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()
    
    var currentIndex = 0
    var presets = [String]()
    var callback: (String) -> Void
    var isPresetLoaded = false
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            isPresetLoaded = false
            let touchLocation = touch.location(in: self)
            if upOuterPath.contains(touchLocation) {
                currentIndex -= 1
                isPresetLoaded = true
            }
            if downOuterPath.contains(touchLocation) {
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
    
    public init(presets: [String], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60), callback: @escaping (String) -> Void) {
        self.callback = callback
        self.presets = presets
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPresetLoader(presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let red = UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let gray = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let darkgray = UIColor(red: 0.735, green: 0.742, blue: 0.736, alpha: 1.000)
        let green = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)
        let dark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Variable Declarations
        let expression = isPresetLoaded ? green : red
        
        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        darkgray.setFill()
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
        presetLabelStyle.alignment = .left
        
        let presetLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: presetLabelStyle]
        
        let presetLabelInset: CGRect = presetLabelRect.insetBy(dx: 10, dy: 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRect(with: CGSize(width: presetLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: presetLabelFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: presetLabelInset)
        presetLabelTextContent.draw(in: CGRect(x: presetLabelInset.minX, y: presetLabelInset.minY + (presetLabelInset.height - presetLabelTextHeight) / 2, width: presetLabelInset.width, height: presetLabelTextHeight), withAttributes: presetLabelFontAttributes)
        context!.restoreGState()
        
        //// upButton
        //// upOuter Drawing
        upOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 0, width: 59, height: 30))
        gray.setFill()
        upOuterPath.fill()
        
        //// upInner Drawing
        let upInnerPath = UIBezierPath()
        upInnerPath.move(to: CGPoint(x: 395.75, y: 22.5))
        upInnerPath.addLine(to: CGPoint(x: 425.25, y: 22.5))
        upInnerPath.addLine(to: CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLine(to: CGPoint(x: 410.5, y: 7.5))
        upInnerPath.addLine(to: CGPoint(x: 395.75, y: 22.5))
        upInnerPath.close()
        dark.setFill()
        upInnerPath.fill()
        
        //// downButton
        //// downOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: 381, y: 30, width: 59, height: 30))
        gray.setFill()
        downOuterPath.fill()
        
        //// downInner Drawing
        let downInnerPath = UIBezierPath()
        downInnerPath.move(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLine(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.addLine(to: CGPoint(x: 425.25, y: 37.5))
        downInnerPath.addLine(to: CGPoint(x: 395.75, y: 37.5))
        downInnerPath.addLine(to: CGPoint(x: 410.5, y: 52.5))
        downInnerPath.close()
        dark.setFill()
        downInnerPath.fill()

        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 95, y: 0, width: 345, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRect(with: CGSize(width: nameLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nameLabelFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: nameLabelInset)
        NSString(string: presetName).draw(in: CGRect(x: nameLabelInset.minX, y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, width: nameLabelInset.width, height: nameLabelTextHeight), withAttributes: nameLabelFontAttributes)
        context!.restoreGState()
    }
    
    override open func draw(_ rect: CGRect) {
        let presetName = isPresetLoaded ? presets[currentIndex] : "None"
        drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
    }
}
