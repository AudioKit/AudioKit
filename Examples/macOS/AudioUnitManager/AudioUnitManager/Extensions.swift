//
//  Extensions.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func indexOf(string: String) -> String.Index? {
        return self.range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func toCGFloat() -> CGFloat {
        if let n = NumberFormatter().number(from: self) {
            let f = CGFloat(truncating: n)
            return f
        }
        return 0.0
    }

    func toInt() -> Int {
        if let n = NumberFormatter().number(from: self) {
            let f = Int(truncating: n)
            return f
        }
        return 0
    }

    func toDouble() -> Double {
        if let n = NumberFormatter().number(from: self) {
            let f = Double(truncating: n)
            return f
        }
        return 0.0
    }

    func startsWith(string: String) -> Bool {
        guard let range = self.range(of: string, options: [.anchored, .caseInsensitive]) else {
            return false
        }

        return range.lowerBound == startIndex
    }

    func removeSpecial() -> String {
        let okayChars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_"
        return self.filter { okayChars.contains($0) }
    }

    func asciiValue() -> [UInt8] {
        var retVal = [UInt8]()
        for val in self.unicodeScalars where val.isASCII {
            retVal.append(UInt8(val.value))
        }
        return retVal
    }

    public static func toClock(_ time: TimeInterval, frameRate: Float = 0) -> String {
        if time.isNaN || time.isInfinite || time.isSignalingNaN {
            return String("-")
        }
        var t = time
        var preroll = ""
        if time < 0 {
            preroll = "-"
        }
        t = abs(t)

        // calculate the minutes in elapsed time.
        let minutes = Int(t / 60.0)
        t -= (TimeInterval(minutes) * 60)

        // calculate the seconds in elapsed time.
        let seconds = Int(t)
        t -= TimeInterval(seconds)

        // find out the fraction of milliseconds to be displayed.
        let mult = Double(frameRate > 0 ? frameRate : 100)
        let fraction = Int(t * mult)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        let out = "\(preroll)\(strMinutes):\(strSeconds):\(strFraction)"
        return out
    }

    public static func toTimecode(frame: Int, fps: Float) -> String {
        let ff = Int(Float(frame).truncatingRemainder(dividingBy: fps))
        let seconds = Int(Float(frame - ff) / fps)
        let ss = seconds % 60
        let mm = (seconds % 3_600) / 60
        let timecode = [String(format: "%02d", mm), String(format: "%02d", ss), String(format: "%02d", ff)]
        return timecode.joined(separator: ":")
    }

    public static func toSimpleClock(_ time: TimeInterval) -> String {
        var t = time
        var preroll = ""
        if time < 0 {
            preroll = "-"
        }
        t = abs(t)

        // calculate the minutes in elapsed time.
        let minutes = Int(t / 60.0)
        t -= (TimeInterval(minutes) * 60)

        // calculate the seconds in elapsed time.
        let seconds = Int(t)
        t -= TimeInterval(seconds)
        let strSeconds = String(format: "%02d", seconds)
        let out = "\(preroll)\(minutes):\(strSeconds)"
        return out
    }
}

extension String.Index {
    func successor(in string: String) -> String.Index {
        return string.index(after: self)
    }

    func predecessor(in string: String) -> String.Index {
        return string.index(before: self)
    }

    func advance(_ offset: Int, for string: String) -> String.Index {
        return string.index(self, offsetBy: offset)
    }
}

extension NSLayoutConstraint {
    public static func simpleVisualConstraints(view: NSView,
                                               direction: NSString = "H",
                                               padding1: Int = 0,
                                               padding2: Int = 0) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint.constraints(
            withVisualFormat: "\(direction):|-\(padding1)-[view]-\(padding2)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["view": view])
        return constraint
    }

    public static func activateConstraintsEqualToSuperview(child: NSView) {
        guard let superview = child.superview else {
            print("NSLayoutConstraint.fillSuperview() superview of child is nil")
            return
        }

        child.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            child.topAnchor.constraint(equalTo: superview.topAnchor),
            child.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}

extension NSView {
    func convertEventToSuperview(theEvent: NSEvent) -> NSPoint {
        let localPoint = self.convert(theEvent.locationInWindow, from: nil)
        let svLocation = self.convert(localPoint, to: self.superview)
        return svLocation
    }

    func convertToSuperview(localPoint: NSPoint) -> NSPoint {
        let svLocation = self.convert(localPoint, to: self.superview)
        return svLocation
    }
}
