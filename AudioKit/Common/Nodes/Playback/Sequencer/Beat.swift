//
//  Beat.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 6/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public extension Double {
    
    /// Calculates beats for a given tempo
    ///
    /// - parameter tempo: Tempo, in beats per minute
    ///
    public func beats(tempo tempo: Double) -> Beat {
        let timeInSecs = self
        let beatsPerSec = tempo / 60.0
        let beatLengthInSecs = Double(1.0 / beatsPerSec)
        return Beat(timeInSecs / beatLengthInSecs)
    }
}

public extension Int {
    
    /// Calculates beats in to a file based on it samples, sample rate, and tempo
    ///
    /// - parameter sampleRate: Sample frequency
    /// - parameter tempo:      Tempo, in beats per minute
    ///
    public func beatsFromSamples(sampleRate sampleRate: Int, tempo: Double) -> Beat {
        let timeInSecs = Double(self) / Double(sampleRate)
        let beatsPerSec = tempo / 60.0
        let beatLengthInSecs = Double(1.0 / beatsPerSec)
        return Beat(timeInSecs / beatLengthInSecs)
    }
}

public struct Beat: CustomStringConvertible {
    public var value: Double
    
    public var musicTimeStamp: MusicTimeStamp {
        return MusicTimeStamp(value)
    }
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public var description: String {
        return "\(value)"
    }
    
    public func seconds(tempo tempo: Double) -> Double {
        return (self.value / tempo) * 60.0
    }

}

public func ceil(beat: Beat) -> Beat {
    return Beat(ceil(beat.value))
}

public func +=(inout lhs: Beat, rhs: Beat) {
    lhs.value = lhs.value + rhs.value
}

public func -=(inout lhs: Beat, rhs: Beat) {
    lhs.value = lhs.value - rhs.value
}

public func ==(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value == rhs.value
}

public func !=(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value != rhs.value
}


public func >=(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value >= rhs.value
}

public func <=(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value <= rhs.value
}

public func <(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value < rhs.value
}

public func >(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.value > rhs.value
}

public func +(lhs: Beat, rhs: Beat) -> Beat {
    return Beat(lhs.value + rhs.value)
}

public func -(lhs: Beat, rhs: Beat) -> Beat {
    return Beat(lhs.value - rhs.value)
}

public func %(lhs: Beat, rhs: Beat) -> Beat {
    return Beat(lhs.value % rhs.value)
}