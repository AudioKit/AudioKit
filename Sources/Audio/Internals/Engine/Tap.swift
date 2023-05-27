// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import AVFoundation
import Foundation
import Utilities

/// Provides a callback that "taps" the audio data from the stream.
public class Tap {

    public typealias Element = ([Float], [Float])

    let tapAU: TapAudioUnit2

    var task: Task<Void, Error>? = nil

    struct WeakTap {
        weak var tap: Tap?

        init(tap: Tap?) {
            self.tap = tap
        }
    }

    static var tapRegistryLock = NSLock()
    static var tapRegistry: [ObjectIdentifier: [WeakTap]] = [:]

    static func getTapsFor(node: Node) -> [Tap] {
        tapRegistryLock.withLock {
            (Self.tapRegistry[ObjectIdentifier(node)] ?? []).compactMap { $0.tap }
        }
    }

    public init(_ input: Node, bufferSize: Int = 1024, tapBlock: @escaping ([Float], [Float]) async -> Void) {

        let componentDescription = AudioComponentDescription(effect: "tap2")

        AUAudioUnit.registerSubclass(TapAudioUnit2.self,
                                     as: componentDescription,
                                     name: "Tap AU2",
                                     version: .max)
        tapAU = instantiateAU(componentDescription: componentDescription) as! TapAudioUnit2
        tapAU.bufferSize = bufferSize

        task = Task { [tapAU, weak input] in

            var left: [Float] = []
            var right: [Float] = []

            while input != nil {
                // Get some new data if we need more.
                while left.count < tapAU.bufferSize {
                    guard !Task.isCancelled else {
                        print("Tap cancelled!")
                        return
                    }

                    if input == nil {
                        // Node went away, so stop the tap
                        return
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

                await tapBlock(leftPrefix, rightPrefix)
            }
        }

        Self.tapRegistryLock.withLock {
            if Self.tapRegistry.keys.contains(ObjectIdentifier(input)) {
                Self.tapRegistry[ObjectIdentifier(input)]?.append(WeakTap(tap: self))
            } else {
                Self.tapRegistry[ObjectIdentifier(input)] = [WeakTap(tap: self)]
            }
        }

        // Trigger a recompile if input already has an associated engine.
        if let engineAU = NodeEnginesManager.shared.getEngine(for: input) {
            print("triggering recompile from Tap.init")
            engineAU.compile()
        }

    }

    deinit {
        task?.cancel()
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

