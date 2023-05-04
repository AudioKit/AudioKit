// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Foundation
import Utilities

/// Provides a callback that "taps" the audio data from the stream.
public class Tap2: AsyncSequence, AsyncIteratorProtocol {

    public typealias Element = ([Float], [Float])

    private weak var input: Node?

    let tapAU: TapAudioUnit2

    struct WeakTap {
        weak var tap: Tap2?

        init(tap: Tap2?) {
            self.tap = tap
        }
    }

    static var tapRegistryLock = NSLock()
    static var tapRegistry: [ObjectIdentifier: [WeakTap]] = [:]

    static func getTapsFor(node: Node) -> [Tap2] {
        tapRegistryLock.withLock {
            (Self.tapRegistry[ObjectIdentifier(node)] ?? []).compactMap { $0.tap }
        }
    }

    public init(_ input: Node, bufferSize: Int = 1024) {
        self.input = input

        let componentDescription = AudioComponentDescription(effect: "tap2")

        AUAudioUnit.registerSubclass(TapAudioUnit2.self,
                                     as: componentDescription,
                                     name: "Tap AU2",
                                     version: .max)
        tapAU = instantiateAU(componentDescription: componentDescription) as! TapAudioUnit2
        tapAU.bufferSize = bufferSize

        Self.tapRegistryLock.withLock {
            if Self.tapRegistry.keys.contains(ObjectIdentifier(input)) {
                Self.tapRegistry[ObjectIdentifier(input)]?.append(WeakTap(tap: self))
            } else {
                Self.tapRegistry[ObjectIdentifier(input)] = [WeakTap(tap: self)]
            }
        }

        // Trigger a recompile if input already has an associated engine.
        if let engineAU = EngineAudioUnit.getEngine(for: input) {
            print("triggering recompile from Tap2.init")
            engineAU.compile()
        }

    }

    private var left: [Float] = []
    private var right: [Float] = []

    public func next() async -> Element? {

        // Get some new data if we need more.
        while left.count < tapAU.bufferSize {
            guard !Task.isCancelled else {
                print("Tap cancelled!")
                return nil
            }

            if input == nil {
                // Node went away, so stop the tap
                return nil
            }

            await withCheckedContinuation({ c in

                // Wait for the next set of samples
                print("waiting for samples")
                _ = tapAU.semaphore.wait(timeout: .now() + 0.1)
                print("done waiting for samples")

                var i = 0
                tapAU.ringBuffer.popAll { sample in
                    if i.isMultiple(of: 2) {
                        left.append(sample)
                    } else {
                        right.append(sample)
                    }
                    i += 1
                }

                c.resume()
            })
        }

        let leftPrefix = Array(left.prefix(tapAU.bufferSize))
        let rightPrefix = Array(right.prefix(tapAU.bufferSize))

        left = Array(left.dropFirst(tapAU.bufferSize))
        right = Array(right.dropFirst(tapAU.bufferSize))

        return (leftPrefix, rightPrefix)
    }

    public func makeAsyncIterator() -> Tap2 {
        self
    }
}

class TapAudioUnit2: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    let ringBuffer = RingBuffer<Float>(capacity: 4096)

    var semaphore = DispatchSemaphore(value: 0)
    var run = true
    var bufferSize = 1024

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override var internalRenderBlock: AUInternalRenderBlock {

        let ringBuffer = self.ringBuffer
        let semaphore = self.semaphore

        return { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Better be stereo.
            assert(ablPointer.count == 2)

            // Check that buffers are the correct size.
            if ablPointer[0].frameCapacity < frameCount {
                print("output buffer 1 too small: \(ablPointer[0].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            if ablPointer[1].frameCapacity < frameCount {
                print("output buffer 2 too small: \(ablPointer[1].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            let outBufL = UnsafeBufferPointer<Float>(ablPointer[0])
            let outBufR = UnsafeBufferPointer<Float>(ablPointer[1])

            print("pushing \(outBufL.count) frames")

            // We are assuming there is enough room in the ring buffer
            // for the all the samples. If not there's nothing we can do.
            _ = ringBuffer.push(interleaving: outBufL, and: outBufR)
            semaphore.signal()

            return noErr
        }
    }

}

/// Node which provides a callback that "taps" the audio data from the stream.
public class Tap: Node {
    public let connections: [Node]

    public let au: AUAudioUnit

    private let tapAU: TapAudioUnit

    /// Create a Tap.
    ///
    /// - Parameters:
    ///   - input: Input to monitor.
    ///   - tapBlock: Called with a stereo pair of channels. Note that this doesn't need to be realtime safe.
    public init(_ input: Node, bufferSize: Int = 1024, tapBlock: @escaping ([Float], [Float]) async -> Void) {
        let componentDescription = AudioComponentDescription(effect: "tapn")

        AUAudioUnit.registerSubclass(TapAudioUnit.self,
                                     as: componentDescription,
                                     name: "Tap AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        tapAU = au as! TapAudioUnit
        tapAU.tapBlock = tapBlock
        tapAU.bufferSize = bufferSize
        connections = [input]
    }
}

class TapAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    let ringBuffer = RingBuffer<Float>(capacity: 4096)

    var tapBlock: ([Float], [Float]) async -> Void = { _, _ in }
    var semaphore = DispatchSemaphore(value: 0)
    var run = true
    var bufferSize = 1024

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])

        let thread = Thread {
            var left: [Float] = []
            var right: [Float] = []

            while true {
                self.semaphore.wait()

                if !self.run {
                    return
                }

                var i = 0
                self.ringBuffer.popAll { sample in
                    if i.isMultiple(of: 2) {
                        left.append(sample)
                    } else {
                        right.append(sample)
                    }
                    i += 1
                }

                while left.count > self.bufferSize {
                    let leftPrefix = Array(left.prefix(self.bufferSize))
                    let rightPrefix = Array(right.prefix(self.bufferSize))

                    left = Array(left.dropFirst(self.bufferSize))
                    right = Array(right.dropFirst(self.bufferSize))

                    Task {
                        await self.tapBlock(leftPrefix, rightPrefix)
                    }
                }
            }
        }
        thread.start()
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override var internalRenderBlock: AUInternalRenderBlock {

        let ringBuffer = self.ringBuffer
        let semaphore = self.semaphore

        return { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Better be stereo.
            assert(ablPointer.count == 2)

            // Check that buffers are the correct size.
            if ablPointer[0].frameCapacity < frameCount {
                print("output buffer 1 too small: \(ablPointer[0].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            if ablPointer[1].frameCapacity < frameCount {
                print("output buffer 2 too small: \(ablPointer[1].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            let outBufL = UnsafeBufferPointer<Float>(ablPointer[0])
            let outBufR = UnsafeBufferPointer<Float>(ablPointer[1])

            // We are assuming there is enough room in the ring buffer
            // for the all the samples. If not there's nothing we can do.
            _ = ringBuffer.push(interleaving: outBufL, and: outBufR)
            semaphore.signal()

            return noErr
        }
    }

}

