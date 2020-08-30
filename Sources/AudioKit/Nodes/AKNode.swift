// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

extension AVAudioConnectionPoint {
    convenience init(_ node: AKNode, to bus: Int) {
        self.init(node: node.avAudioUnitOrNode, bus: bus)
    }
}

/// Parent class for all nodes in AudioKit
open class AKNode {

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// The internal AVAudioUnit, which is a subclass of AVAudioNode with more capabilities
    open var avAudioUnit: AVAudioUnit? {
        didSet {
            guard let avAudioUnit = avAudioUnit else { return }

            let mirror = Mirror(reflecting: self)

            for child in mirror.children {
                if let param = child.value as? ParameterBase, let label = child.label {
                    // Property wrappers create a variable with an underscore
                    // prepended. Drop the underscore to look up the parameter.
                    let name = String(label.dropFirst())
                    param.projectedValue.associate(with: avAudioUnit,
                                                   identifier: name)
                }
            }
        }
    }

    /// Returns either the avAudioUnit or avAudioNode (prefers the avAudioUnit if it exists)
    open var avAudioUnitOrNode: AVAudioNode {
        return self.avAudioUnit ?? self.avAudioNode
    }

    /// Initialize the node from an AVAudioUnit
    public init(avAudioUnit: AVAudioUnit, attach: Bool = false) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
        if attach {
            AKManager.engine.attach(avAudioUnit)
        }
    }

    /// Initialize the node from an AVAudioNode
    public init(avAudioNode: AVAudioNode, attach: Bool = false) {
        self.avAudioNode = avAudioNode
        if attach {
            AKManager.engine.attach(avAudioNode)
        }
    }

    deinit {
        detach()
    }

    /// Subclasses should override to detach all internal nodes
    open func detach() {
        AKManager.detach(nodes: [avAudioUnitOrNode])
    }
}

extension AKNode: AKOutput {
    public var outputNode: AVAudioNode {
        return self.avAudioUnitOrNode
    }
}

/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: AUValue, channel: MIDIChannel)

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    func stop(noteNumber: MIDINoteNumber)
}

/// Bare bones implementation of AKPolyphonic protocol
open class AKPolyphonicNode: AKNode, AKPolyphonic {
    /// Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    @objc public static var tuningTable = AKTuningTable()
    open var midiInstrument: AVAudioUnitMIDIInstrument?

    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    ///
    open func play(noteNumber: MIDINoteNumber,
                   velocity: MIDIVelocity,
                   frequency: AUValue,
                   channel: MIDIChannel = 0) {
        AKLog("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), channel: \(channel), " +
            "override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        // MARK: Microtonal pitch lookup

        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: AUValue(frequency), channel: channel)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
    }
}

/// Protocol for dictating that a node can be in a started or stopped state
public protocol AKToggleable {
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }

    /// Function to start, play, or activate the node, all do the same thing
    func start()

    /// Function to stop or bypass the node, both are equivalent
    func stop()
}

/// Default functions for nodes that conform to AKToggleable
public extension AKToggleable {
    /// Synonym for isStarted that may make more sense with musical instruments
    var isPlaying: Bool {
        return isStarted
    }

    /// Antonym for isStarted
    var isStopped: Bool {
        return !isStarted
    }

    /// Antonym for isStarted that may make more sense with effects
    var isBypassed: Bool {
        return !isStarted
    }

    /// Synonym to start that may more more sense with musical instruments
    func play() {
        start()
    }

    /// Synonym for stop that may make more sense with effects
    func bypass() {
        stop()
    }
}

public extension AKToggleable where Self: AKComponent {

    var isStarted: Bool {
        return (internalAU as? AKAudioUnitBase)?.isStarted ?? false
    }

    func start() {
        (internalAU as? AKAudioUnitBase)?.start()
    }

    func stop() {
        (internalAU as? AKAudioUnitBase)?.stop()
    }
}

public extension AKToggleable where Self: AKComponent2 {

    var isStarted: Bool {
        return (internalAU as? AKAudioUnitBase)?.isStarted ?? false
    }

    func start() {
        (internalAU as? AKAudioUnitBase)?.start()
    }

    func stop() {
        (internalAU as? AKAudioUnitBase)?.stop()
    }
}

struct AKNodeConnection {
    var node: AKNode2
    var bus: Int
}

open class AKNode2 {

    var connections: [AKNodeConnection] = []

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// The internal AVAudioUnit, which is a subclass of AVAudioNode with more capabilities
    open var avAudioUnit: AVAudioUnit? {
        didSet {
            guard let avAudioUnit = avAudioUnit else { return }

            let mirror = Mirror(reflecting: self)

            for child in mirror.children {
                if let param = child.value as? ParameterBase, let label = child.label {
                    // Property wrappers create a variable with an underscore
                    // prepended. Drop the underscore to look up the parameter.
                    let name = String(label.dropFirst())
                    param.projectedValue.associate(with: avAudioUnit,
                                                   identifier: name)
                }
            }
        }
    }

    /// Returns either the avAudioUnit or avAudioNode (prefers the avAudioUnit if it exists)
    open var avAudioUnitOrNode: AVAudioNode {
        return self.avAudioUnit ?? self.avAudioNode
    }

    /// Initialize the node from an AVAudioUnit
    public init(avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
    }

    /// Initialize the node from an AVAudioNode
    public init(avAudioNode: AVAudioNode) {
        self.avAudioNode = avAudioNode
    }

    deinit {
        if let engine = self.avAudioNode.engine {
            engine.detach(self.avAudioNode)
        }
    }

}

@discardableResult public func >>> (left: AKNode2, right: AKNode2) -> AKNode2 {
    right.connections.append(AKNodeConnection(node: left, bus: 0))
    return right
}

public class AKEngine {

    let avEngine = AVAudioEngine()

    public init() { }

    public var output: AKNode2? {
        didSet {
            if let node = output {
                attach(node: node)
                avEngine.connect(node.avAudioNode, to: avEngine.outputNode)
            }
        }
    }

    func attach(node: AKNode2) {

        avEngine.attach(node.avAudioNode)

        for connection in node.connections {
            attach(node: connection.node)
            avEngine.connect(connection.node.avAudioNode, to: node.avAudioNode)
        }
    }

    public func start() throws {
        try avEngine.start()
    }

    public func stop() {
        avEngine.stop()
    }

    /// Test the output of a given node
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///   - afterStart: Closure to execute at the beginning of the test
    ///
    /// - Returns: MD5 hash of audio output for comparison with test baseline.
    public func test(node: AKNode2, duration: Double, afterStart: () -> Void = {}) throws -> String {

        var digestHex = ""

        #if swift(>=3.2)
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            let samples = Int(duration * AKSettings.sampleRate)

            output = node

            // maximum number of frames the engine will be asked to render in any single render call
            let maximumFrameCount: AVAudioFrameCount = 4_096
            try AKTry {
                self.avEngine.reset()
                try self.avEngine.enableManualRenderingMode(.offline,
                                                     format: AKSettings.audioFormat,
                                                     maximumFrameCount: maximumFrameCount)
                try self.avEngine.start()
            }

            afterStart()

            let md5state = UnsafeMutablePointer<md5_state_s>.allocate(capacity: 1)
            md5_init(md5state)
            var samplesHashed = 0

            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: avEngine.manualRenderingFormat,
                frameCapacity: avEngine.manualRenderingMaximumFrameCount) else { return "" }

            while avEngine.manualRenderingSampleTime < samples {
                let framesToRender = buffer.frameCapacity
                let status = try avEngine.renderOffline(framesToRender, to: buffer)
                switch status {
                case .success:
                    // data rendered successfully
                    if let floatChannelData = buffer.floatChannelData {

                        for frame in 0 ..< framesToRender {
                            for channel in 0 ..< buffer.format.channelCount where samplesHashed < samples {
                                let sample = floatChannelData[Int(channel)][Int(frame)]
                                withUnsafeBytes(of: sample) { samplePtr in
                                    if let baseAddress = samplePtr.bindMemory(to: md5_byte_t.self).baseAddress {
                                        md5_append(md5state, baseAddress, 4)
                                    }
                                }
                                samplesHashed += 1
                            }
                        }

                    }

                case .insufficientDataFromInputNode:
                    // applicable only if using the input node as one of the sources
                    break

                case .cannotDoInCurrentContext:
                    // engine could not render in the current render call, retry in next iteration
                    break

                case .error:
                    // error occurred while rendering
                    fatalError("render failed")
                @unknown default:
                    fatalError("Unknown render result")
                }
            }

            var digest = [md5_byte_t](repeating: 0, count: 16)

            digest.withUnsafeMutableBufferPointer { digestPtr in
                md5_finish(md5state, digestPtr.baseAddress)
            }

            for index in 0..<16 {
                digestHex += String(format: "%02x", digest[index])
            }

            md5state.deallocate()

        }
        #endif

        return digestHex
    }

    /// Audition the test to hear what it sounds like
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///
    public func auditionTest(node: AKNode2, duration: Double, afterStart: () -> Void = {}) throws {
        output = node

        try avEngine.start()

        // if the engine isn't running you need to give it time to get its act together before
        // playing, otherwise the start of the audio is cut off
        if !avEngine.isRunning {
            usleep(UInt32(1_000_000))
        }

        afterStart()
        if let playableNode = node as? AKToggleable {
            playableNode.play()
        }
        usleep(UInt32(duration * 1_000_000))
    }

}
