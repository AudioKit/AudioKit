//
//  Beat.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 6/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

//public typealias Beat = Double

public struct Beat {
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
}

public func ceil(beat: Beat) -> Beat {
    return Beat(ceil(beat.value))
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