//
//  AVAudioTimeShim.swift
//  AudioKit
//
//  Created by David O'Neill on 5/8/17.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// Utility to convert between host time and seconds
private let ticksToSeconds: Double = {
    var tinfo = mach_timebase_info()
    let err = mach_timebase_info(&tinfo)
    let timecon = Double(tinfo.numer) / Double(tinfo.denom)
    return timecon * 0.000_000_001
}()
/// Utility to convert between seconds to host time.
private let secondsToTicks: Double = {
    var tinfo = mach_timebase_info()
    let err = mach_timebase_info(&tinfo)
    let timecon = Double(tinfo.denom) / Double(tinfo.numer)
    return timecon * 1_000_000_000
}()

extension AVAudioTime {

    /// AVAudioTime.extrapolateTime fails for host time valid times, use
    /// extrapolateTimeShimmed instead. https://bugreport.apple.com/web/?problemID=34249528
    open func extrapolateTimeShimmed(fromAnchor anchorTime: AVAudioTime) -> AVAudioTime {
        guard ((isSampleTimeValid && sampleRate == anchorTime.sampleRate) || isHostTimeValid) &&
            !(isSampleTimeValid && isHostTimeValid) &&
            anchorTime.isSampleTimeValid && anchorTime.isHostTimeValid else {
                return self
        }
        if isSampleTimeValid && sampleRate == anchorTime.sampleRate {
            let secondsDiff = Double(sampleTime - anchorTime.sampleTime) / anchorTime.sampleRate
            let hostTime = anchorTime.hostTime + secondsDiff / ticksToSeconds
            return AVAudioTime(hostTime: hostTime, sampleTime: sampleTime, atRate: anchorTime.sampleRate)
        } else {
            let secondsDiff = Double(hostTime.safeSubtract(anchorTime.hostTime)) * ticksToSeconds
            let sampleTime = anchorTime.sampleTime + AVAudioFramePosition(round(secondsDiff * anchorTime.sampleRate))
            let audioTime = AVAudioTime(hostTime: hostTime, sampleTime: sampleTime, atRate: anchorTime.sampleRate)
            return audioTime
        }
    }

    /// An AVAudioTime with a valid hostTime representing now.
    open static func now() -> AVAudioTime {
        return AVAudioTime(hostTime: mach_absolute_time())
    }

    /// Returns an AVAudioTime offest by seconds.
    open func offset(seconds: Double) -> AVAudioTime {

        if isSampleTimeValid && isHostTimeValid {
            return AVAudioTime(hostTime: hostTime + seconds / ticksToSeconds,
                               sampleTime: sampleTime + AVAudioFramePosition(seconds * sampleRate),
                               atRate: sampleRate)
        } else if isSampleTimeValid {
            return AVAudioTime(sampleTime: sampleTime + AVAudioFramePosition(seconds * sampleRate),
                               atRate: sampleRate)
        } else if isHostTimeValid {
            return AVAudioTime(hostTime: hostTime + seconds / ticksToSeconds)
        }
        return self
    }

    /// The time in seconds between reciever and otherTime.
    open func timeIntervalSince(otherTime: AVAudioTime) -> Double? {
        if isSampleTimeValid && otherTime.isSampleTimeValid {
            return Double(sampleTime - otherTime.sampleTime) / sampleRate
        }
        if isHostTimeValid && otherTime.isHostTimeValid {
            return Double(hostTime.safeSubtract(otherTime.hostTime)) * ticksToSeconds
        }
        if isSampleTimeValid && isHostTimeValid {
            let completeTime = otherTime.extrapolateTimeShimmed(fromAnchor: self)
            return Double(sampleTime - completeTime.sampleTime) / sampleRate
        }
        if otherTime.isHostTimeValid && otherTime.isSampleTimeValid {
            let completeTime = self.extrapolateTimeShimmed(fromAnchor: otherTime)
            return Double(completeTime.sampleTime - otherTime.sampleTime) / sampleRate
        }
        return nil
    }

}

public func + (left: AVAudioTime, right: Double) -> AVAudioTime {
    return left.offset(seconds: right)
}
public func + (left: AVAudioTime, right: Int) -> AVAudioTime {
    return left.offset(seconds: Double(right))
}

fileprivate extension UInt64 {
    func safeSubtract(_ other: UInt64) -> Int64 {
        return self > other ? Int64(self - other) : -Int64(other - self)
    }
    static func + (left: UInt64, right: Double) -> UInt64 {
        return right >= 0 ? left + UInt64(right) : left - UInt64(-right)
    }
}
