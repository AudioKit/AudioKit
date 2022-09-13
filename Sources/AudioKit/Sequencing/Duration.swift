// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Type alias for Tempo to make it clear when we're working with tempo in beats per minute
public typealias BPM = Double

import AVFoundation

/// Container for the notion of time in sequencing
public struct Duration: CustomStringConvertible, Comparable {
    static let secondsPerMinute = 60

    /// Duration in beats
    public var beats: Double

    /// Samples per second
    public var sampleRate: Double = Settings.sampleRate

    /// Tempo in BPM (beats per minute)
    public var tempo: BPM = 60.0

    /// While samples is the most accurate, they blow up too fast, so using beat as standard
    public var samples: Int {
        get {
            let doubleSamples = beats / tempo * Double(Duration.secondsPerMinute) * sampleRate
            if doubleSamples <= Double(Int.max) {
                return Int(doubleSamples)
            } else {
                Log("Warning: Samples exceeds the maximum number.")
                return .max
            }
        }
        set {
            beats = (Double(newValue) / Double(sampleRate)) / Double(Duration.secondsPerMinute) * tempo
        }
    }

    /// Regular time measurement
    public var seconds: Double {
        return Double(samples) / sampleRate
    }

    /// Useful for math using tempo in BPM (beats per minute)
    public var minutes: Double {
        return seconds / 60.0
    }

    /// Music time stamp for the duration in beats
    public var musicTimeStamp: MusicTimeStamp {
        return MusicTimeStamp(beats)
    }

    /// Pretty printout
    public var description: String {
        return "\(samples) samples at \(sampleRate) = \(beats) Beats at \(tempo) BPM = \(seconds)s"
    }

    /// Initialize with samples
    ///
    /// - Parameters:
    ///   - samples:    Number of samples
    ///   - sampleRate: Sample rate in samples per second
    ///
    public init(samples: Int, sampleRate: Double = Settings.sampleRate, tempo: BPM = 60) {
        beats = tempo * (Double(samples) / sampleRate) / Double(Duration.secondsPerMinute)
        self.sampleRate = sampleRate
        self.tempo = tempo
    }

    /// Initialize from a beat perspective
    ///
    /// - Parameters:
    ///   - beats: Duration in beats
    ///   - tempo: Durations per minute
    ///
    public init(beats: Double, tempo: BPM = 60) {
        self.beats = beats
        self.tempo = tempo
    }

    /// Initialize from a normal time perspective
    ///
    /// - Parameters:
    ///   - seconds:    Duration in seconds
    ///   - sampleRate: Samples per second
    ///
    public init(seconds: Double, sampleRate: Double = Settings.sampleRate, tempo: BPM = 60) {
        self.sampleRate = sampleRate
        self.tempo = tempo
        beats = tempo * (seconds / Double(Duration.secondsPerMinute))
    }

    /// Add to a duration
    ///
    /// - parameter lhs: Starting duration
    /// - parameter rhs: Amount to add
    ///
    public static func += (lhs: inout Duration, rhs: Duration) {
        lhs.beats += rhs.beats
    }

    /// Subtract from a duration
    ///
    /// - parameter lhs: Starting duration
    /// - parameter rhs: Amount to subtract
    ///
    public static func -= (lhs: inout Duration, rhs: Duration) {
        lhs.beats -= rhs.beats
    }

    /// Duration equality
    ///
    /// - parameter lhs: One duration
    /// - parameter rhs: Another duration
    ///
    public static func == (lhs: Duration, rhs: Duration) -> Bool {
        return lhs.beats == rhs.beats
    }

    /// Duration less than
    ///
    /// - parameter lhs: One duration
    /// - parameter rhs: Another duration
    ///
    public static func < (lhs: Duration, rhs: Duration) -> Bool {
        return lhs.beats < rhs.beats
    }

    /// Adding durations
    ///
    /// - parameter lhs: One duration
    /// - parameter rhs: Another duration
    ///
    public static func + (lhs: Duration, rhs: Duration) -> Duration {
        var newDuration = lhs
        newDuration.beats += rhs.beats
        return newDuration
    }

    /// Subtracting durations
    ///
    /// - parameter lhs: One duration
    /// - parameter rhs: Another duration
    ///
    public static func - (lhs: Duration, rhs: Duration) -> Duration {
        var newDuration = lhs
        newDuration.beats -= rhs.beats
        return newDuration
    }

    /// Modulus of the duration's beats
    ///
    /// - parameter lhs: One duration
    /// - parameter rhs: Another duration
    ///
    public static func % (lhs: Duration, rhs: Duration) -> Duration {
        var copy = lhs
        copy.beats = lhs.beats.truncatingRemainder(dividingBy: rhs.beats)
        return copy
    }
}

/// Upper bound of a duration, in beats
///
/// - parameter duration: Duration
///
public func ceil(_ duration: Duration) -> Duration {
    var copy = duration
    copy.beats = ceil(copy.beats)
    return copy
}
