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

/// Class to cycle through good colors
public class AKColorPalette {
    public static let sharedInstance = AKColorPalette()

    let colors: [AKColor] = [AKColor.red, AKColor.green]

    var counter = 0

    public var next: AKColor {
        get {
            counter += 1
            if counter >= colors.count {
                counter = 0
            }
            return colors[counter]
        }
    }

}
