// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Superclass for STK physical models, do not use directly
public class STKBase: Node, MIDITriggerable  {
    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode
    
    /// Initialize the STK Clarinet model
    public init(_ code: String) {
        avAudioNode = instantiate(instrument: code)
    }
}

/// STK Clarinet
public class Clarinet: STKBase {
    /// Initialize the physical model
    public init() { super.init("clar")}
}

/// STK Flute
public class Flute: STKBase {
    /// Initialize the physical model
    public init() { super.init("flut")}
}

/// STK Mandole
public class MandolinString: STKBase {
    /// Initialize the physical model
    public init() { super.init("mand")}
}

/// STK Rhodes Piano
public class RhodesPianoKey: STKBase {
    /// Initialize the physical model
    public init() { super.init("rhds")}
}

/// STK Shaker
public class Shaker: STKBase {
    /// Initialize the physical model
    public init() { super.init("shak")}
}

/// STK Tubuluar Bells
public class TubularBells: STKBase {
    /// Initialize the physical model
    public init() { super.init("tbel")}
}

extension Shaker {
    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - type: various shaker types are supported
    ///   - amplitude: how hard to shake
    public func trigger(type: ShakerType, amplitude: Double = 0.5) {
        let velocity = MIDIVelocity(amplitude * 127.0)
        au.trigger(note: type.rawValue, velocity: velocity)
    }
}

/// Type of shaker to use
public enum ShakerType: MIDIByte {

    /// Maraca
    case maraca = 0

    /// Cabasa
    case cabasa = 1

    /// Sekere
    case sekere = 2

    /// Tambourine
    case tambourine = 3

    /// Sleigh Bells
    case sleighBells = 4

    /// Bamboo Chimes
    case bambooChimes = 5

    /// Using sand paper
    case sandPaper = 6

    /// Soda Can
    case sodaCan = 7

    /// Sticks falling
    case sticks = 8

    /// Crunching sound
    case crunch = 9

    /// Big rocks hitting each other
    case bigRocks = 10

    /// Little rocks hitting each other
    case littleRocks = 11

    /// NeXT Mug
    case nextMug = 12

    /// A penny rattling around a mug
    case pennyInMug = 13

    /// A nickle rattling around a mug
    case nickleInMug = 14

    /// A dime rattling around a mug
    case dimeInMug = 15

    /// A quarter rattling around a mug
    case quarterInMug = 16

    /// A Franc rattling around a mug
    case francInMug = 17

    /// A Peso rattling around a mug
    case pesoInMug = 18

    /// Guiro
    case guiro = 19

    /// Wrench
    case wrench = 20

    /// Water Droplets
    case waterDrops = 21

    /// Tuned Bamboo Chimes
    case tunedBambooChimes = 22
}

