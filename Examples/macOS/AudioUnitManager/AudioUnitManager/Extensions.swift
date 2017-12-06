//
//  Extensions.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 7/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
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
        return self.range( of:string, options: .literal, range: nil, locale: nil)?.lowerBound
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

        guard let range = self.range( of: string, options:[.anchored, .caseInsensitive]) else {
            return false
        }

        return range.lowerBound == startIndex
    }

    func removeSpecial() -> String {
        let okayChars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_"
        return self.filter {okayChars.contains($0) }
    }

    func asciiValue() -> [UInt8] {

        var retVal = [UInt8]()
        for val in self.unicodeScalars where val.isASCII {

            retVal.append(UInt8(val.value))
        }
        return retVal
    }

}

extension String.Index {
    func successor(in string: String) -> String.Index {
        return string.index(after: self)
    }

    func predecessor(in string: String) -> String.Index {
        return string.index(before: self)
    }

    func advance(_ offset: Int, `for` string: String) -> String.Index {
        return string.index(self, offsetBy: offset)
    }
}

extension NSLayoutConstraint {
    public static func simpleVisualConstraints( view: NSView, direction: NSString = "H", padding1: Int = 0, padding2: Int = 0 ) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint.constraints(withVisualFormat: "\(direction):|-\(padding1)-[view]-\(padding2)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["view": view])
        return constraint
    }

    public static func activateConstraintsEqualToSuperview( child: NSView ) {
        if child.superview == nil {
            Swift.print("NSLayoutConstraint.fillSuperview() superview of child is nil")
            return
        }

        child.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate( [
            child.leadingAnchor.constraint( equalTo: child.superview!.leadingAnchor ),
            child.trailingAnchor.constraint( equalTo: child.superview!.trailingAnchor ),
            child.topAnchor.constraint( equalTo: child.superview!.topAnchor ),
            child.bottomAnchor.constraint( equalTo: child.superview!.bottomAnchor )
            ])
    }

}
