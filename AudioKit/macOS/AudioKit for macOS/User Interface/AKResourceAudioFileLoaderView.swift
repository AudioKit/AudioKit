//
//  AKResourceAudioFileLoaderView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa

public class AKResourcesAudioFileLoaderView: NSView {
    
    var player: AKAudioPlayer?
    var stopOuterPath = NSBezierPath()
    var playOuterPath = NSBezierPath()
    var upOuterPath   = NSBezierPath()
    var downOuterPath = NSBezierPath()
    
    var currentIndex = 0
    var titles = [String]()
    
    override public func mouseDown(with theEvent: NSEvent) {
        var isFileChanged = false
        let isPlayerPlaying = player!.isPlaying
        let touchLocation = convert(theEvent.locationInWindow, from: nil)
        if stopOuterPath.contains(touchLocation) {
            player?.stop()
        }
        if playOuterPath.contains(touchLocation) {
            player?.play()
        }
        if upOuterPath.contains(touchLocation) {
            currentIndex -= 1
            isFileChanged = true
        }
        if downOuterPath.contains(touchLocation) {
            currentIndex += 1
            isFileChanged = true
        }
        if currentIndex < 0 { currentIndex = titles.count - 1 }
        if currentIndex >= titles.count { currentIndex = 0 }
        
        if isFileChanged {
            player?.stop()
            let filename = titles[currentIndex]
            let file = try? AKAudioFile(readFileName: "\(filename)", baseDir: .resources)
            do {
                try player?.replaceFile(file!)
            } catch {
                Swift.print("Could not replace file")
            }
            if isPlayerPlaying { player?.play() }
        }
        needsDisplay = true
    }
    
    public convenience init(player: AKAudioPlayer,
                            filenames: [String],
                            frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.init(frame: frame)
        self.player = player
        self.titles = filenames
    }
    
    func drawAudioFileLoader(sliderColor: NSColor = NSColor(calibratedRed: 1, green: 0, blue: 0.062, alpha: 1), fileName: String = "None") {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.current()!.graphicsPort, to: CGContext.self)
        
        //// Color Declarations
        let backgroundColor = NSColor(calibratedRed: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let color = NSColor(calibratedRed: 0.029, green: 1, blue: 0, alpha: 1)
        let dark = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        
        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSMakeRect(0, 0, 440, 60))
        backgroundColor.setFill()
        backgroundPath.fill()
        
        
        //// stopButton
        //// stopOuter Drawing
        stopOuterPath = NSBezierPath(rect: NSMakeRect(0, 0, 60, 60))
        sliderColor.setFill()
        stopOuterPath.fill()
        
        
        //// stopInner Drawing
        let stopInnerPath = NSBezierPath(rect: NSMakeRect(15, 15, 30, 30))
        dark.setFill()
        stopInnerPath.fill()
        
        
        
        
        //// playButton
        //// playOuter Drawing
        playOuterPath = NSBezierPath(rect: NSMakeRect(60, 0, 60, 60))
        color.setFill()
        playOuterPath.fill()
        
        
        //// playInner Drawing
        let playInnerPath = NSBezierPath()
        playInnerPath.move(to: NSMakePoint(76.5, 45))
        playInnerPath.line(to: NSMakePoint(76.5, 15))
        playInnerPath.line(to: NSMakePoint(106.5, 30))
        dark.setFill()
        playInnerPath.fill()
        
        
        
        
        //// upButton
        //// upOuter Drawing
        upOuterPath = NSBezierPath(rect: NSMakeRect(381, 30, 59, 30))
        backgroundColor.setFill()
        upOuterPath.fill()
        
        
        //// upInner Drawing
        let upInnerPath = NSBezierPath()
        upInnerPath.move(to: NSMakePoint(395.75, 37.5))
        upInnerPath.line(to: NSMakePoint(425.25, 37.5))
        upInnerPath.line(to: NSMakePoint(410.5, 52.5))
        upInnerPath.line(to: NSMakePoint(410.5, 52.5))
        upInnerPath.line(to: NSMakePoint(395.75, 37.5))
        upInnerPath.close()
        dark.setFill()
        upInnerPath.fill()
        
        
        
        
        //// downButton
        //// downOuter Drawing
        downOuterPath = NSBezierPath(rect: NSMakeRect(381, 0, 59, 30))
        backgroundColor.setFill()
        downOuterPath.fill()
        
        
        //// downInner Drawing
        let downInnerPath = NSBezierPath()
        downInnerPath.move(to: NSMakePoint(410.5, 7.5))
        downInnerPath.line(to: NSMakePoint(410.5, 7.5))
        downInnerPath.line(to: NSMakePoint(425.25, 22.5))
        downInnerPath.line(to: NSMakePoint(395.75, 22.5))
        downInnerPath.line(to: NSMakePoint(410.5, 7.5))
        downInnerPath.close()
        dark.setFill()
        downInnerPath.fill()
        
        
        
        
        //// nameLabel Drawing
        let nameLabelRect = NSMakeRect(120, 0, 320, 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        
        let nameLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!, NSForegroundColorAttributeName: NSColor.black, NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = NSInsetRect(nameLabelRect, 10, 0)
        let nameLabelTextHeight: CGFloat = NSString(string: fileName).boundingRect(with: NSMakeSize(nameLabelInset.width, CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSMakeRect(nameLabelInset.minX, nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, nameLabelInset.width, nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(nameLabelInset)
        NSString(string: fileName).draw(in: NSOffsetRect(nameLabelTextRect, 0, 0), withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    
    override public func draw(_ rect: CGRect) {
        drawAudioFileLoader(fileName: titles[currentIndex])
    }
}
