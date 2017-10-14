//
//  AKResourceAudioFileLoaderView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public class AKResourcesAudioFileLoaderView: NSView {

    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    var player: AKAudioPlayer?
    var stopOuterPath = NSBezierPath()
    var playOuterPath = NSBezierPath()
    var upOuterPath = NSBezierPath()
    var downOuterPath = NSBezierPath()

    var currentIndex = 0
    var titles = [String]()

    open var bgColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var textColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var borderColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var borderWidth: CGFloat = 3.0 {
        didSet {
            needsDisplay = true
        }
    }

    /// Initialize the resource loader
    public convenience init(player: AKAudioPlayer,
                            filenames: [String],
                            frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.init(frame: frame)
        self.player = player
        self.titles = filenames
    }

    /// Handle click
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

    // Default background color per theme
    var bgColorForTheme: AKColor {
        if let bgColor = bgColor { return bgColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.8, alpha: 1.0)
        case .midnight: return AKColor(white: 0.7, alpha: 1.0)
        }
    }

    // Default border color per theme
    var borderColorForTheme: AKColor {
        if let borderColor = borderColor { return borderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0).withAlphaComponent(0.8)
        case .midnight: return AKColor.white.withAlphaComponent(0.8)
        }
    }

    // Default text color per theme
    var textColorForTheme: AKColor {
        if let textColor = textColor { return textColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    func drawAudioFileLoader(sliderColor: NSColor = AKStylist.sharedInstance.colorForFalseValue,
                             fileName: String = "None") {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.current?.graphicsPort, to: CGContext.self)
        let rect = bounds

        let cornerRadius: CGFloat = AKResourcesAudioFileLoaderView.standardCornerRadius

        //// Color Declarations
        let backgroundColor = bgColorForTheme
        let color = AKStylist.sharedInstance.colorForTrueValue
        let dark = textColorForTheme

        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: borderWidth,
                                                       y: borderWidth,
                                                       width: rect.width - borderWidth * 2.0,
                                                       height: rect.height - borderWidth * 2.0))
        backgroundColor.setFill()
        backgroundPath.fill()

        //// stopButton
        //// stopOuter Drawing
        stopOuterPath = NSBezierPath(rect: NSRect(x: borderWidth,
                                                  y: borderWidth,
                                                  width: rect.width * 0.13,
                                                  height: rect.height - borderWidth * 2.0))
        sliderColor.setFill()
        stopOuterPath.fill()

        //// stopInner Drawing
        let stopInnerPath = NSBezierPath(roundedRect: NSRect(x: (rect.width * 0.13 - rect.height * 0.5) / 2 + cornerRadius,
                                                             y: rect.height * 0.25,
                                                             width: rect.height * 0.5,
                                                             height: rect.height * 0.5),
                                         xRadius: cornerRadius,
                                         yRadius: cornerRadius)
        dark.setFill()
        stopInnerPath.fill()

        //// playButton
        //// playOuter Drawing
        playOuterPath = NSBezierPath(rect: NSRect(x: rect.width * 0.13 + borderWidth,
                                                  y: borderWidth,
                                                  width: rect.width * 0.13,
                                                  height: rect.height - borderWidth * 2.0))
        color.setFill()
        playOuterPath.fill()

        //// playInner Drawing
        let playRect = NSRect(x: (rect.width * 0.13 - rect.height * 0.5) / 2 + borderWidth + rect.width * 0.13 + borderWidth,
                              y: rect.height * 0.25,
                              width: rect.height * 0.5,
                              height: rect.height * 0.5)
        let playInnerPath = NSBezierPath()
        playInnerPath.move(to: NSPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.maxY))
        playInnerPath.line(to: NSPoint(x: playRect.maxX - cornerRadius / 2.0, y: playRect.midY + cornerRadius / 2.0))
        playInnerPath.curve(to: NSPoint(x: playRect.maxX - cornerRadius / 2.0,
                                        y: playRect.midY - cornerRadius / 2.0),
                            controlPoint1: NSPoint(x: playRect.maxX, y: playRect.midY),
                            controlPoint2: NSPoint(x: playRect.maxX, y: playRect.midY))
        playInnerPath.line(to: NSPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.minY))
        playInnerPath.curve(to: NSPoint(x: playRect.minX, y: playRect.minY + cornerRadius / 2.0),
                            controlPoint1: NSPoint(x: playRect.minX, y: playRect.minY),
                            controlPoint2: NSPoint(x: playRect.minX, y: playRect.minY))
        playInnerPath.line(to: NSPoint(x: playRect.minX, y: playRect.maxY - cornerRadius / 2.0))
        playInnerPath.curve(to: NSPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.maxY),
                            controlPoint1: NSPoint(x: playRect.minX, y: playRect.maxY),
                            controlPoint2: NSPoint(x: playRect.minX, y: playRect.maxY))
        playInnerPath.close()
        dark.setFill()
        playInnerPath.fill()
        dark.setStroke()
        playInnerPath.stroke()

        // stopButton border Path
        let stopButtonBorderPath = NSBezierPath()
        stopButtonBorderPath.move(to: NSPoint(x: rect.width * 0.13 + borderWidth, y: borderWidth))
        stopButtonBorderPath.line(to: NSPoint(x: rect.width * 0.13 + borderWidth, y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        stopButtonBorderPath.lineWidth = borderWidth / 2.0
        stopButtonBorderPath.stroke()

        // playButton border Path
        let playButtonBorderPath = NSBezierPath()
        playButtonBorderPath.move(to: NSPoint(x: rect.width * 0.13 * 2.0 + borderWidth, y: borderWidth))
        playButtonBorderPath.line(to: NSPoint(x: rect.width * 0.13 * 2.0 + borderWidth, y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        playButtonBorderPath.lineWidth = borderWidth / 2.0
        playButtonBorderPath.stroke()

        //// upButton
        //// upOuter Drawing
        upOuterPath = NSBezierPath(rect: NSRect(x: rect.width * 0.9,
                                                y: rect.height * 0.5,
                                                width: rect.width * 0.07,
                                                height: rect.height * 0.5))

        //// upInner Drawing
        let upperArrowRect = NSRect(x: rect.width * 0.9,
                                    y: rect.height * 0.58,
                                    width: rect.width * 0.07,
                                    height: rect.height * 0.3)
        let upInnerPath = NSBezierPath()
        upInnerPath.move(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.minY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.maxX - cornerRadius / 2.0, y: upperArrowRect.minY))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.maxX - cornerRadius / 2.0,
                                      y: upperArrowRect.minY + cornerRadius / 2.0),
                          controlPoint1: NSPoint(x: upperArrowRect.maxX, y: upperArrowRect.minY),
                          controlPoint2: NSPoint(x: upperArrowRect.maxX, y: upperArrowRect.minY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.midX + cornerRadius / 2.0,
                                     y: upperArrowRect.maxY - cornerRadius / 2.0))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.midX - cornerRadius / 2.0,
                                      y: upperArrowRect.maxY - cornerRadius / 2.0),
                          controlPoint1: NSPoint(x: upperArrowRect.midX, y: upperArrowRect.maxY),
                          controlPoint2: NSPoint(x: upperArrowRect.midX, y: upperArrowRect.maxY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0,
                                     y: upperArrowRect.minY + cornerRadius / 2.0))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.minY),
                          controlPoint1: NSPoint(x: upperArrowRect.minX, y: upperArrowRect.minY),
                          controlPoint2: NSPoint(x: upperArrowRect.minX, y: upperArrowRect.minY))
        textColorForTheme.setStroke()
        upInnerPath.lineWidth = borderWidth
        upInnerPath.stroke()

        downOuterPath = NSBezierPath(rect: NSRect(x: rect.width * 0.9,
                                                  y: 0,
                                                  width: rect.width * 0.07,
                                                  height: rect.height * 0.5))

        //// downInner Drawing
        let downArrowRect = NSRect(x: rect.width * 0.9,
                                   y: rect.height * 0.12,
                                   width: rect.width * 0.07,
                                   height: rect.height * 0.3)
        let downInnerPath = NSBezierPath()
        downInnerPath.move(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.maxY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.maxX - cornerRadius / 2.0, y: downArrowRect.maxY))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.maxX - cornerRadius / 2.0,
                                        y: downArrowRect.maxY - cornerRadius / 2.0),
                            controlPoint1: NSPoint(x: downArrowRect.maxX, y: downArrowRect.maxY),
                            controlPoint2: NSPoint(x: downArrowRect.maxX, y: downArrowRect.maxY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.midX + cornerRadius / 2.0,
                                       y: downArrowRect.minY + cornerRadius / 2.0))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.midX - cornerRadius / 2.0,
                                        y: downArrowRect.minY + cornerRadius / 2.0),
                            controlPoint1: NSPoint(x: downArrowRect.midX, y: downArrowRect.minY),
                            controlPoint2: NSPoint(x: downArrowRect.midX, y: downArrowRect.minY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                       y: downArrowRect.maxY - cornerRadius / 2.0))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                        y: downArrowRect.maxY),
                            controlPoint1: NSPoint(x: downArrowRect.minX, y: downArrowRect.maxY),
                            controlPoint2: NSPoint(x: downArrowRect.minX, y: downArrowRect.maxY))
        textColorForTheme.setStroke()
        downInnerPath.lineWidth = borderWidth
        downInnerPath.stroke()

        //// nameLabel Drawing
        let nameLabelRect = NSRect(x: 120, y: 0, width: 320, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 24.0),
                                       NSAttributedStringKey.foregroundColor: textColorForTheme,
                                       NSAttributedStringKey.paragraphStyle: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: fileName).boundingRect(
            with: NSSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSString.DrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        __NSRectClip(nameLabelInset)
        NSString(string: fileName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                        withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0,
                               y: rect.origin.y + borderWidth / 2.0,
                               width: rect.width - borderWidth,
                               height: rect.height - borderWidth)

        let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: cornerRadius, yRadius: cornerRadius)
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()
    }

    /// Draw the resource loader
    override public func draw(_ rect: CGRect) {
        drawAudioFileLoader(fileName: titles[currentIndex])
    }
}
