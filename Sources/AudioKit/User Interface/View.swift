// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
    import Cocoa
    public typealias CrossPlatformView = NSView
    public typealias CrossPlatformColor = NSColor
#else
    import UIKit
    public typealias CrossPlatformView = UIView
    public typealias CrossPlatformColor = UIColor
#endif

/// Class to handle colors, fonts, etc.

public enum Theme {
    case basic
    case midnight
}

public class Stylist {
    public static let sharedInstance = Stylist()

    public var bgColor: CrossPlatformColor {
        return bgColors[theme]!
    }

    public var fontColor: CrossPlatformColor {
        return fontColors[theme]!
    }

    public var theme = Theme.midnight
    private var bgColors: [Theme: CrossPlatformColor]
    private var fontColors: [Theme: CrossPlatformColor]

    private var colorCycle: [Theme: [CrossPlatformColor]]

    var counter = 0

    init() {
        fontColors = Dictionary()
        fontColors[.basic] = CrossPlatformColor.black
        fontColors[.midnight] = CrossPlatformColor.white

        bgColors = Dictionary()
        bgColors[.basic] = CrossPlatformColor.white
        bgColors[.midnight] = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)

        colorCycle = Dictionary()
        colorCycle[.basic] = [CrossPlatformColor(red: 165.0 / 255.0, green: 26.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
                              CrossPlatformColor(red: 238.0 / 255.0, green: 66.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0),
                              CrossPlatformColor(red: 244.0 / 255.0, green: 96.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0),
                              CrossPlatformColor(red: 36.0 / 255.0, green: 110.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0),
                              CrossPlatformColor(red: 14.0 / 255.0, green: 173.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)]
        colorCycle[.midnight] = [CrossPlatformColor(red: 165.0 / 255.0, green: 26.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
                                 CrossPlatformColor(red: 238.0 / 255.0, green: 66.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0),
                                 CrossPlatformColor(red: 244.0 / 255.0, green: 96.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0),
                                 CrossPlatformColor(red: 36.0 / 255.0, green: 110.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0),
                                 CrossPlatformColor(red: 14.0 / 255.0, green: 173.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)]
    }

    public var nextColor: CrossPlatformColor {
        counter += 1
        if let currentColorCycle = colorCycle[theme] {
            if counter >= currentColorCycle.count {
                counter = 0
            }
            return currentColorCycle[counter]
        } else {
            fatalError()
        }
    }

    public var colorForTrueValue: CrossPlatformColor {
        switch theme {
        case .basic:
            return CrossPlatformColor(red: 35.0 / 255.0, green: 206.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        case .midnight:
            return CrossPlatformColor(red: 35.0 / 255.0, green: 206.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        }
    }

    public var colorForFalseValue: CrossPlatformColor {
        switch theme {
        case .basic:
            return CrossPlatformColor(red: 255.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0, alpha: 1.0)
        case .midnight:
            return CrossPlatformColor(red: 255.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0, alpha: 1.0)
        }
    }
}
