// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// Tap Tempo class by Joel Perry
// https://gist.github.com/joel-perry/17e02a92ae93d7208887

import Foundation

class TapTempo {
    private let timeOutInterval: TimeInterval
    private let minTaps: Int
    private var taps: [NSDate] = []

    init(timeOut: TimeInterval, minimumTaps: Int) {
        timeOutInterval = timeOut
        minTaps = minimumTaps
    }

    func addTap() -> Double? {
        let thisTap = NSDate()

        if let lastTap = taps.last {
            if thisTap.timeIntervalSince(lastTap as Date) > timeOutInterval {
                taps.removeAll()
            }
        }

        taps.append(thisTap)
        guard taps.count >= minTaps else { return nil }
        guard let firstTap = taps.first else { return nil }

        let avgIntervals = thisTap.timeIntervalSince(firstTap as Date) / Double(taps.count - 1)
        return 60.0 / avgIntervals
    }
}
