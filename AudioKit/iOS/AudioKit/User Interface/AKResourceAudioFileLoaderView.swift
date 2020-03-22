//
//  AKResourceAudioFileLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import AudioKit

/// View to choose from audio files to use in playgrounds
@IBDesignable open class AKResourcesAudioFileLoaderView: UIView {

    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    var player: AKPlayer?
    var stopOuterPath = UIBezierPath()
    var playOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()

    var currentIndex = 0
    var titles = [String]()

    open var bgColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var textColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var borderColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var borderWidth: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Handle touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var isFileChanged = false
            guard let isPlayerPlaying = player?.isPlaying else {
                return
            }
            let touchLocation = touch.location(in: self)
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
                    player?.load(audioFile: file)
                }
                if isPlayerPlaying { player?.play() }
                setNeedsDisplay()
            }
        }
    }

    /// Initialize the resource loader
    public convenience init(player: AKPlayer,
                            filenames: [String],
                            frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.init(frame: frame)
        self.player = player
        self.titles = filenames
    }

    /// Initialization with no details
    public override init(frame: CGRect) {
        self.titles = ["File One", "File Two", "File Three"]

        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }

    /// Initialize in Interface Builder
    public required init?(coder aDecoder: NSCoder) {
        self.titles = ["File One", "File Two", "File Three"]

        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }

    // Default background color per theme
    var bgColorForTheme: AKColor {
        if let bgColor = bgColor {
            return bgColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.8, alpha: 1.0)
        case .midnight:
            return AKColor(white: 0.7, alpha: 1.0)
        }
    }

    // Default border color per theme
    var borderColorForTheme: AKColor {
        if let borderColor = borderColor {
            return borderColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0).withAlphaComponent(0.8)
        case .midnight:
            return AKColor.white.withAlphaComponent(0.8)
        }
    }

    // Default text color per theme
    var textColorForTheme: AKColor {
        if let textColor = textColor {
            return textColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0)
        case .midnight:
            return AKColor.white
        }
    }

    func drawAudioFileLoader(sliderColor: AKColor = AKStylist.sharedInstance.colorForFalseValue,
                             fileName: String = "None") {
        //// General Declarations
        let rect = bounds
        let cornerRadius: CGFloat = AKResourcesAudioFileLoaderView.standardCornerRadius

        //// Color Declarations
        let backgroundColor = bgColorForTheme
        let color = AKStylist.sharedInstance.colorForTrueValue
        let dark = textColorForTheme

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: borderWidth,
                                                       y: borderWidth,
                                                       width: rect.width - borderWidth * 2.0,
                                                       height: rect.height - borderWidth * 2.0))
        backgroundColor.setFill()
        backgroundPath.fill()

        //// stopButton
        //// stopOuter Drawing
        stopOuterPath = UIBezierPath(rect: CGRect(x: borderWidth,
                                                  y: borderWidth,
                                                  width: rect.width * 0.13,
                                                  height: rect.height - borderWidth * 2.0))
        sliderColor.setFill()
        stopOuterPath.fill()

        //// stopInner Drawing
        let stopInnerPath = UIBezierPath(roundedRect:
            CGRect(x: (rect.width * 0.13 - rect.height * 0.5) / 2 + cornerRadius,
                   y: rect.height * 0.25,
                   width: rect.height * 0.5,
                   height: rect.height * 0.5), cornerRadius: cornerRadius)
        dark.setFill()
        stopInnerPath.fill()

        //// playButton
        //// playOuter Drawing
        playOuterPath = UIBezierPath(rect: CGRect(x: rect.width * 0.13 + borderWidth,
                                                  y: borderWidth,
                                                  width: rect.width * 0.13,
                                                  height: rect.height - borderWidth * 2.0))
        color.setFill()
        playOuterPath.fill()

        //// playInner Drawing
        let playRect = CGRect(x: (rect.width * 0.13 - rect.height * 0.5) / 2 +
            borderWidth + rect.width * 0.13 + borderWidth,
                              y: rect.height * 0.25,
                              width: rect.height * 0.5,
                              height: rect.height * 0.5)
        let playInnerPath = UIBezierPath()
        playInnerPath.move(to: CGPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.maxY))
        playInnerPath.addLine(to: CGPoint(x: playRect.maxX - cornerRadius / 2.0, y: playRect.midY + cornerRadius / 2.0))
        playInnerPath.addCurve(to: CGPoint(x: playRect.maxX - cornerRadius / 2.0,
                                        y: playRect.midY - cornerRadius / 2.0),
                            controlPoint1: CGPoint(x: playRect.maxX, y: playRect.midY),
                            controlPoint2: CGPoint(x: playRect.maxX, y: playRect.midY))
        playInnerPath.addLine(to: CGPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.minY))
        playInnerPath.addCurve(to: CGPoint(x: playRect.minX, y: playRect.minY + cornerRadius / 2.0),
                            controlPoint1: CGPoint(x: playRect.minX, y: playRect.minY),
                            controlPoint2: CGPoint(x: playRect.minX, y: playRect.minY))
        playInnerPath.addLine(to: CGPoint(x: playRect.minX, y: playRect.maxY - cornerRadius / 2.0))
        playInnerPath.addCurve(to: CGPoint(x: playRect.minX + cornerRadius / 2.0, y: playRect.maxY),
                            controlPoint1: CGPoint(x: playRect.minX, y: playRect.maxY),
                            controlPoint2: CGPoint(x: playRect.minX, y: playRect.maxY))
        playInnerPath.close()
        dark.setFill()
        playInnerPath.fill()
        dark.setStroke()
        playInnerPath.stroke()

        // stopButton border Path
        let stopButtonBorderPath = UIBezierPath()
        stopButtonBorderPath.move(to: CGPoint(x: rect.width * 0.13 + borderWidth,
                                              y: borderWidth))
        stopButtonBorderPath.addLine(to: CGPoint(x: rect.width * 0.13 + borderWidth,
                                                 y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        stopButtonBorderPath.lineWidth = borderWidth / 2.0
        stopButtonBorderPath.stroke()

        // playButton border Path
        let playButtonBorderPath = UIBezierPath()
        playButtonBorderPath.move(to: CGPoint(x: rect.width * 0.13 * 2.0 + borderWidth,
                                              y: borderWidth))
        playButtonBorderPath.addLine(to: CGPoint(x: rect.width * 0.13 * 2.0 + borderWidth,
                                                 y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        playButtonBorderPath.lineWidth = borderWidth / 2.0
        playButtonBorderPath.stroke()

        //// upButton
        //// upOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: rect.width * 0.9,
                                                y: rect.height * 0.5,
                                                width: rect.width * 0.07,
                                                height: rect.height * 0.5))

        //// upInner Drawing
        let downArrowRect = CGRect(x: rect.width * 0.9,
                                    y: rect.height * 0.58,
                                    width: rect.width * 0.07,
                                    height: rect.height * 0.3)
        let downInnerPath = UIBezierPath()
        downInnerPath.move(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.minY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.maxX - cornerRadius / 2.0, y: downArrowRect.minY))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.maxX - cornerRadius / 2.0,
                                      y: downArrowRect.minY + cornerRadius / 2.0),
                          controlPoint1: CGPoint(x: downArrowRect.maxX, y: downArrowRect.minY),
                          controlPoint2: CGPoint(x: downArrowRect.maxX, y: downArrowRect.minY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.midX + cornerRadius / 2.0,
                                     y: downArrowRect.maxY - cornerRadius / 2.0))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.midX - cornerRadius / 2.0,
                                      y: downArrowRect.maxY - cornerRadius / 2.0),
                          controlPoint1: CGPoint(x: downArrowRect.midX, y: downArrowRect.maxY),
                          controlPoint2: CGPoint(x: downArrowRect.midX, y: downArrowRect.maxY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                     y: downArrowRect.minY + cornerRadius / 2.0))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.minY),
                          controlPoint1: CGPoint(x: downArrowRect.minX, y: downArrowRect.minY),
                          controlPoint2: CGPoint(x: downArrowRect.minX, y: downArrowRect.minY))
        textColorForTheme.setStroke()
        downInnerPath.lineWidth = borderWidth
        downInnerPath.stroke()

        upOuterPath = UIBezierPath(rect: CGRect(x: rect.width * 0.9,
                                                  y: 0,
                                                  width: rect.width * 0.07,
                                                  height: rect.height * 0.5))

        //// downInner Drawing
        let upperArrowRect = CGRect(x: rect.width * 0.9,
                                   y: rect.height * 0.12,
                                   width: rect.width * 0.07,
                                   height: rect.height * 0.3)
        let upInnerPath = UIBezierPath()
        upInnerPath.move(to: CGPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.maxY))
        upInnerPath.addLine(to: CGPoint(x: upperArrowRect.maxX - cornerRadius / 2.0, y: upperArrowRect.maxY))
        upInnerPath.addCurve(to: CGPoint(x: upperArrowRect.maxX - cornerRadius / 2.0,
                                        y: upperArrowRect.maxY - cornerRadius / 2.0),
                            controlPoint1: CGPoint(x: upperArrowRect.maxX, y: upperArrowRect.maxY),
                            controlPoint2: CGPoint(x: upperArrowRect.maxX, y: upperArrowRect.maxY))
        upInnerPath.addLine(to: CGPoint(x: upperArrowRect.midX + cornerRadius / 2.0,
                                       y: upperArrowRect.minY + cornerRadius / 2.0))
        upInnerPath.addCurve(to: CGPoint(x: upperArrowRect.midX - cornerRadius / 2.0,
                                        y: upperArrowRect.minY + cornerRadius / 2.0),
                            controlPoint1: CGPoint(x: upperArrowRect.midX, y: upperArrowRect.minY),
                            controlPoint2: CGPoint(x: upperArrowRect.midX, y: upperArrowRect.minY))
        upInnerPath.addLine(to: CGPoint(x: upperArrowRect.minX + cornerRadius / 2.0,
                                       y: upperArrowRect.maxY - cornerRadius / 2.0))
        upInnerPath.addCurve(to: CGPoint(x: upperArrowRect.minX + cornerRadius / 2.0,
                                        y: upperArrowRect.maxY),
                            controlPoint1: CGPoint(x: upperArrowRect.minX, y: upperArrowRect.maxY),
                            controlPoint2: CGPoint(x: upperArrowRect.minX, y: upperArrowRect.maxY))
        textColorForTheme.setStroke()
        upInnerPath.lineWidth = borderWidth
        upInnerPath.stroke()

        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 120, y: 0, width: 320, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24.0),
                                       NSAttributedString.Key.foregroundColor: textColorForTheme,
                                       NSAttributedString.Key.paragraphStyle: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: fileName).boundingRect(
            with: CGSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes, context: nil).size.height
        let nameLabelTextRect: CGRect = CGRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSString(string: fileName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                        withAttributes: nameLabelFontAttributes)

        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0,
                               y: rect.origin.y + borderWidth / 2.0,
                               width: rect.width - borderWidth,
                               height: rect.height - borderWidth)

        let outerPath = UIBezierPath(roundedRect: outerRect, cornerRadius: cornerRadius)
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()
    }

    open override func draw(_ rect: CGRect) {
        drawAudioFileLoader(fileName: titles[currentIndex])
    }
}
