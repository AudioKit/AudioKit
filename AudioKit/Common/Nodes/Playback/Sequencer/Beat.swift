//
//  Beat.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 6/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public typealias BPM = Double

public struct AKDuration: CustomStringConvertible {
    let secondsPerMinute = 60

    /// The sample is the most precise unit of time measurement we can possibly have
    public var samples: Int
    
    /// Samples per second
    public var sampleRate: Double = 44100
    
    /// Regular time measurement
    public var seconds: Double {
        return Double(samples) / sampleRate
    }
    
    /// Useful for math using tempo in BPM (beats per minute)
    public var minutes: Double {
        return seconds / 60.0
    }

    /// Tempo in BPM (beats per minute)
    public var tempo: BPM = 60.0
    
    /// Duration in beats
    public var beats: Double {
        didSet {
            samples = Int(beats / tempo * secondsPerMinute * sampleRate)
        }
    }
    
    public var musicTimeStamp: MusicTimeStamp {
        return MusicTimeStamp(beats)
    }
    
    /// Pretty printout
    public var description: String {
        return "\(samples) samples at \(sampleRate) = \(beats) Beats at \(tempo) BPM = \(seconds)s"
    }
    
//    public func seconds(tempo tempo: Double) -> Double {
//        return (self.beats / tempo) * 60.0
//    }
    
    /// Initialize with samples
    ///
    /// - Parameters:
    ///   - samples:    Number of samples
    ///   - sampleRate: Sample rate in samples per second
    ///
    public init(samples: Int, sampleRate: Double = 44100, tempo: BPM = 60) {
        self.samples = samples
        self.beats = tempo * (samples / sampleRate) / secondsPerMinute
        self.sampleRate = sampleRate
    }

    /// Initialize from a beat perspective
    ///
    /// - Parameters:
    ///   - beats: Duration in beats
    ///   - tempo: AKDurations per minute
    ///
    public init(beats: Double, tempo: BPM = 60) {
        self.beats = beats
        self.tempo = tempo
        self.samples = Int((beats / tempo) * secondsPerMinute * sampleRate)
    }

    /// Initialize from a normal time perspective
    ///
    /// - Parameters:
    ///   - seconds:    Duration in seconds
    ///   - sampleRate: Samples per second (Default: 44100)
    ///
    public init(seconds: Double, sampleRate: Double = 44100, tempo: BPM = 60) {
        self.sampleRate = sampleRate
        self.tempo = tempo
        self.samples = Int(seconds * sampleRate)
        self.beats = tempo * (samples / sampleRate) / secondsPerMinute
    }
}


public func ceil(duration: AKDuration) -> AKDuration {
    var copy = duration
    copy.beats = ceil(copy.beats)
    return copy
}

public func +=(inout lhs: AKDuration, rhs: AKDuration) {
    lhs.beats = lhs.beats + rhs.beats
}

public func -=(inout lhs: AKDuration, rhs: AKDuration) {
    lhs.beats = lhs.beats - rhs.beats
}

public func ==(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats == rhs.beats
}

public func !=(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats != rhs.beats
}


public func >=(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats >= rhs.beats
}

public func <=(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats <= rhs.beats
}

public func <(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats < rhs.beats
}

public func >(lhs: AKDuration, rhs: AKDuration) -> Bool {
    return lhs.beats > rhs.beats
}

public func +(lhs: AKDuration, rhs: AKDuration) -> AKDuration {
    var newDuration = lhs
    newDuration.beats += rhs.beats
    return newDuration
}

public func -(lhs: AKDuration, rhs: AKDuration) -> AKDuration {
    var newDuration = lhs
    newDuration.beats -= rhs.beats
    return newDuration
}

public func %(lhs: AKDuration, rhs: AKDuration) -> AKDuration {
    var copy = lhs
    copy.beats = lhs.beats % rhs.beats
    return copy
}
