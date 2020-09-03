// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

extension AVAudioNode {

    public func disconnect(input: AVAudioNode) {
        if let engine = engine {
            for bus in 0 ..< numberOfInputs {
                if let cp = engine.inputConnectionPoint(for: self, inputBus: bus) {
                    if cp.node === input {
                        engine.disconnectNodeInput(self, bus: bus)
                    }
                }
            }
        }
    }

}

public class AKEngine {

    // TODO make this internal
    public let avEngine = AVAudioEngine()

    public init() { }

    public var output: AKNode? {
        didSet {
            if let node = oldValue {
                avEngine.mainMixerNode.disconnect(input: node.avAudioNode)
            }
            if let node = output {
                avEngine.attach(node.avAudioNode)
                node.makeAVConnections()
                avEngine.connect(node.avAudioNode, to: avEngine.mainMixerNode)
            }
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
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///   - afterStart: Closure to execute at the beginning of the test
    ///
    /// - Returns: MD5 hash of audio output for comparison with test baseline.
    public func test(duration: Double, afterStart: () -> Void = {}) throws -> String {

        var digestHex = ""

        #if swift(>=3.2)
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            let samples = Int(duration * AKSettings.sampleRate)

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
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///   - afterStart: Block of code to run before audition
    ///
    public func auditionTest(duration: Double, afterStart: () -> Void = {}) throws {
        try avEngine.start()

        // if the engine isn't running you need to give it time to get its act together before
        // playing, otherwise the start of the audio is cut off
        if !avEngine.isRunning {
            usleep(UInt32(1_000_000))
        }

        afterStart()
        usleep(UInt32(duration * 1_000_000))
    }

    /// Enumerate the list of available input devices.
    public static var inputDevices: [AKDevice]? {
        #if os(macOS)
        return AudioDeviceUtils.devices().compactMap { (id: AudioDeviceID) -> AKDevice? in
            if AudioDeviceUtils.inputChannels(id) > 0 {
                return AKDevice(deviceID: id)
            }
            return nil
        }
        #else
        var returnDevices = [AKDevice]()
        if let devices = AVAudioSession.sharedInstance().availableInputs {
            for device in devices {
                if device.dataSources == nil || device.dataSources?.isEmpty == true {
                    returnDevices.append(AKDevice(portDescription: device))

                } else if let dataSources = device.dataSources {
                    for dataSource in dataSources {
                        returnDevices.append(AKDevice(name: device.portName,
                                                      deviceID: "\(device.uid) \(dataSource.dataSourceName)"))
                    }
                }
            }
            return returnDevices
        }
        return nil
        #endif
    }

    /// Enumerate the list of available output devices.
    public static var outputDevices: [AKDevice]? {
        #if os(macOS)
        return AudioDeviceUtils.devices().compactMap { (id: AudioDeviceID) -> AKDevice? in
            if AudioDeviceUtils.outputChannels(id) > 0 {
                return AKDevice(deviceID: id)
            }
            return nil
        }
        #else
        let devs = AVAudioSession.sharedInstance().currentRoute.outputs
        if devs.isNotEmpty {
            var outs = [AKDevice]()
            for dev in devs {
                outs.append(AKDevice(name: dev.portName, deviceID: dev.uid))
            }
            return outs
        }
        return nil
        #endif
    }

    #if os(macOS)
    /// Enumerate the list of available devices.
    public static var devices: [AKDevice]? {
        return AudioDeviceUtils.devices().map { id in
            return AKDevice(deviceID: id)
        }
    }
    #endif

    /// Change the preferred input device, giving it one of the names from the list of available inputs.
    public static func setInputDevice(_ input: AKDevice) throws {
        #if os(macOS)
        try AKTry {
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster)
            var devid = input.deviceID
            AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &devid)
        }
        #else
        // Set the port description first eg iPhone Microphone / Headset Microphone etc
        guard let portDescription = input.portDescription else {
            throw AKError.DeviceNotFound
        }
        try AVAudioSession.sharedInstance().setPreferredInput(portDescription)

        // Set the data source (if any) eg. Back/Bottom/Front microphone
        guard let dataSourceDescription = input.dataSource else {
            return
        }
        try AVAudioSession.sharedInstance().setInputDataSource(dataSourceDescription)
        #endif
    }

    /// The current input device, if available.
    ///
    /// Note that on macOS, this will always be the same as `outputDevice`
    public var inputDevice: AKDevice? {
        #if os(macOS)
        return AKDevice(deviceID: avEngine.getDevice())
        #else
        if let portDescription = AVAudioSession.sharedInstance().preferredInput {
            return AKDevice(portDescription: portDescription)
        } else {
            let inputDevices = AVAudioSession.sharedInstance().currentRoute.inputs
            if inputDevices.isNotEmpty {
                for device in inputDevices {
                    return AKDevice(portDescription: device)
                }
            }
        }
        return nil
        #endif
    }

    /// The current output device, if available.
    ///
    /// Note that on macOS, this will always be the same as `inputDevice`
    public var outputDevice: AKDevice? {
        #if os(macOS)
        return AKDevice(deviceID: avEngine.getDevice())
        #else
        let devs = AVAudioSession.sharedInstance().currentRoute.outputs
        if devs.isNotEmpty {
            return AKDevice(name: devs[0].portName, deviceID: devs[0].uid)
        }
        return nil
        #endif
    }


    /// Change the preferred output device, giving it one of the names from the list of available output.
    public func setOutputDevice(_ output: AKDevice) throws {
        #if os(macOS)
        avEngine.setDevice(id: output.deviceID)
        #endif
    }

    // TODO write a test for render to file

    /// Render output to an AVAudioFile for a duration.
    ///
    /// NOTE: This will NOT render sequencer content;
    /// MIDI content will need to be recorded in real time
    ///
    ///     - Parameters:
    ///         - audioFile: A file initialized for writing
    ///         - duration: Duration to render, in seconds
    ///         - prerender: Closure called before rendering starts, used to start players, set initial parameters, etc.
    ///         - progress: Closure called while rendering, use this to fetch render progress
    ///
    @available(iOS 11, macOS 10.13, tvOS 11, *)
    public func renderToFile(_ audioFile: AVAudioFile,
                             maximumFrameCount: AVAudioFrameCount = 4_096,
                             duration: Double,
                             prerender: (() -> Void)? = nil,
                             progress: ((Double) -> Void)? = nil) throws {

        try avEngine.renderToFile(audioFile,
                                  maximumFrameCount: maximumFrameCount,
                                  duration: duration,
                                  prerender: prerender,
                                  progress: progress)
    }
}
