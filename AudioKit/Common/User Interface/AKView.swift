//
//  AKView.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#if os(macOS)
    public typealias AKView = NSView
    public typealias AKColor = NSColor
#else
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
        colorCycle[.basic] = [AKColor.red, AKColor.green]
        colorCycle[.midnight] = [AKColor(red: 66.0 / 255.0, green: 129.0 / 255.0, blue: 164.0 / 244.0, alpha: 1.0),
                                 AKColor(red: 254.0 / 255.0, green: 147.0 / 255.0, blue: 140.0 / 244.0, alpha: 1.0),
                                 AKColor(red: 230.0 / 255.0, green: 184.0 / 255.0, blue: 156.0 / 244.0, alpha: 1.0),
                                 AKColor(red: 234.0 / 255.0, green: 210.0 / 255.0, blue: 172.0 / 244.0, alpha: 1.0),
                                 AKColor(red: 156.0 / 255.0, green: 175.0 / 255.0, blue: 183.0 / 244.0, alpha: 1.0)]
    }

    public var nextColor: AKColor {
        get {
            counter += 1
            if counter >= colorCycle[theme]!.count {
                counter = 0
            }
            return colorCycle[theme]![counter]
        }
    }
}
