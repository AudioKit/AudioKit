// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
    import Cocoa
    public typealias AKView = NSView
    public typealias AKColor = NSColor
#else
    import UIKit
    public typealias AKView = UIView
    public typealias AKColor = UIColor
#endif

/// Class to handle colors, fonts, etc.

public enum AKTheme {
    case basic
    case midnight
}

public class AKStylist {
    public static let sharedInstance = AKStylist()

    public var bgColor: AKColor {
        return bgColors[theme]!
    }

    public var fontColor: AKColor {
        return fontColors[theme]!
    }

    public var theme = AKTheme.midnight
    private var bgColors: [AKTheme: AKColor]
    private var fontColors: [AKTheme: AKColor]

    private var colorCycle: [AKTheme: [AKColor]]

    var counter = 0

    init() {
        fontColors = Dictionary()
        fontColors[.basic] = AKColor.black
        fontColors[.midnight] = AKColor.white

        bgColors = Dictionary()
        bgColors[.basic] = AKColor.white
        bgColors[.midnight] = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)

        colorCycle = Dictionary()
        colorCycle[.basic] = [AKColor(red: 165.0 / 255.0, green: 26.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
                              AKColor(red: 238.0 / 255.0, green: 66.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0),
                              AKColor(red: 244.0 / 255.0, green: 96.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0),
                              AKColor(red: 36.0 / 255.0, green: 110.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0),
                              AKColor(red: 14.0 / 255.0, green: 173.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)]
        colorCycle[.midnight] = [AKColor(red: 165.0 / 255.0, green: 26.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0),
                                 AKColor(red: 238.0 / 255.0, green: 66.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0),
                                 AKColor(red: 244.0 / 255.0, green: 96.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0),
                                 AKColor(red: 36.0 / 255.0, green: 110.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0),
                                 AKColor(red: 14.0 / 255.0, green: 173.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)]
    }

    public var nextColor: AKColor {
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

    public var colorForTrueValue: AKColor {
        switch theme {
        case .basic:
            return AKColor(red: 35.0 / 255.0, green: 206.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        case .midnight:
            return AKColor(red: 35.0 / 255.0, green: 206.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        }
    }

    public var colorForFalseValue: AKColor {
        switch theme {
        case .basic:
            return AKColor(red: 255.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0, alpha: 1.0)
        case .midnight:
            return AKColor(red: 255.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0, alpha: 1.0)
        }
    }
}
