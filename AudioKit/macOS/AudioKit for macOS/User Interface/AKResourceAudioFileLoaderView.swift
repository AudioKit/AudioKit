//
//  AKResourceAudioFileLoaderView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public class AKResourcesAudioFileLoaderView: NSView {

    var player: AKAudioPlayer?
    var stopOuterPath = NSBezierPath()
    var playOuterPath = NSBezierPath()
    var upOuterPath = NSBezierPath()
    var downOuterPath = NSBezierPath()

    var currentIndex = 0
    var titles = [String]()

    override public func mouseDown(with theEvent: NSEvent) {
        var isFileChanged = false
        guard let isPlayerPlaying = player?.isPlaying else {
            return
        }
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
            if let file = try? AKAudioFile(readFileName: "\(filename)", baseDir: .resources) {
                do {
                    try player?.replace(file: file)
                } catch {
                    Swift.print("Could not replace file")
                }
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

    func drawAudioFileLoader(sliderColor: NSColor = #colorLiteral(red: 1, green: 0, blue: 0.062, alpha: 1),
                             fileName: String = "None") {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.current()?.graphicsPort, to: CGContext.self)

        //// Color Declarations
        let backgroundColor = #colorLiteral(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let color = #colorLiteral(red: 0.029, green: 1, blue: 0, alpha: 1)
        let dark = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 440, height: 60))
        backgroundColor.setFill()
        backgroundPath.fill()

        //// stopButton
        //// stopOuter Drawing
        stopOuterPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 60, height: 60))
        sliderColor.setFill()
        stopOuterPath.fill()

        //// stopInner Drawing
        let stopInnerPath = NSBezierPath(rect: NSRect(x: 15, y: 15, width: 30, height: 30))
        dark.setFill()
        stopInnerPath.fill()

        //// playButton
        //// playOuter Drawing
        playOuterPath = NSBezierPath(rect: NSRect(x: 60, y: 0, width: 60, height: 60))
        color.setFill()
        playOuterPath.fill()

        //// playInner Drawing
        let playInnerPath = NSBezierPath()
        playInnerPath.move(to: NSPoint(x: 76.5, y: 45))
        playInnerPath.line(to: NSPoint(x: 76.5, y: 15))
        playInnerPath.line(to: NSPoint(x: 106.5, y: 30))
        dark.setFill()
        playInnerPath.fill()

        //// upButton
        //// upOuter Drawing
        upOuterPath = NSBezierPath(rect: NSRect(x: 381, y: 30, width: 59, height: 30))
        backgroundColor.setFill()
        upOuterPath.fill()

        //// upInner Drawing
        let upInnerPath = NSBezierPath()
        upInnerPath.move(to: NSPoint(x: 395.75, y: 37.5))
        upInnerPath.line(to: NSPoint(x: 425.25, y: 37.5))
        upInnerPath.line(to: NSPoint(x: 410.5, y: 52.5))
        upInnerPath.line(to: NSPoint(x: 410.5, y: 52.5))
        upInnerPath.line(to: NSPoint(x: 395.75, y: 37.5))
        upInnerPath.close()
        dark.setFill()
        upInnerPath.fill()

        //// downButton
        //// downOuter Drawing
        downOuterPath = NSBezierPath(rect: NSRect(x: 381, y: 0, width: 59, height: 30))
        backgroundColor.setFill()
        downOuterPath.fill()

        //// downInner Drawing
        let downInnerPath = NSBezierPath()
        downInnerPath.move(to: NSPoint(x: 410.5, y: 7.5))
        downInnerPath.line(to: NSPoint(x: 410.5, y: 7.5))
        downInnerPath.line(to: NSPoint(x: 425.25, y: 22.5))
        downInnerPath.line(to: NSPoint(x: 395.75, y: 22.5))
        downInnerPath.line(to: NSPoint(x: 410.5, y: 7.5))
        downInnerPath.close()
        dark.setFill()
        downInnerPath.fill()

        //// nameLabel Drawing
        let nameLabelRect = NSRect(x: 120, y: 0, width: 320, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24),
                                       NSForegroundColorAttributeName: NSColor.black,
                                       NSParagraphStyleAttributeName: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: fileName).boundingRect(
            with: NSSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(nameLabelInset)
        NSString(string: fileName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                        withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    override public func draw(_ rect: CGRect) {
        drawAudioFileLoader(fileName: titles[currentIndex])
    }
}
