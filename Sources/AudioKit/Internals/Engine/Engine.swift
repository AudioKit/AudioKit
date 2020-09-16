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

    /// Make a connection without breaking other connections.
    public func connect(input: AVAudioNode, bus: Int) {
        if let engine = engine {
            var points = engine.outputConnectionPoints(for: input, outputBus: 0)
            if points.contains(where: { $0.node === self }) { return }
            points.append(AVAudioConnectionPoint(node: self, bus: bus))
            engine.connect(input, to: points, fromBus: 0, format: nil)
        }
    }
}

public class AKEngine {
    // TODO: make this internal
    public let avEngine = AVAudioEngine()

    // maximum number of frames the engine will be asked to render in any single render call
    let maximumFrameCount: AVAudioFrameCount = 1_024

    public class InputNode: AKMixer {
        var isNotConnected = true

        func connect(to engine: AKEngine) {
            engine.avEngine.attach(avAudioNode)
            engine.avEngine.connect(engine.avEngine.inputNode, to: avAudioNode, format: nil)
        }
    }

    let _input = InputNode()
    public var input: InputNode {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") as? String else {
            fatalError("To use the microphone, you must include the NSMicrophoneUsageDescription in your Info.plist")
        }
        if _input.isNotConnected {
            _input.connect(to: self)
            _input.isNotConnected = false
        }
        return _input
    }

    public init() {}

    public var output: AKNode? {
        didSet {
            if let node = oldValue {
                avEngine.mainMixerNode.disconnect(input: node.avAudioNode)
                node.detach()
            }
            if let node = output {
                avEngine.attach(node.avAudioNode)
                node.makeAVConnections()
                avEngine.connect(node.avAudioNode, to: avEngine.mainMixerNode, format: nil)
            }
        }
    }

    public func start() throws {
        if output == nil {
            AKLog("🛑 Error: Attempt to start engine with no output.")
            return
        }
        try avEngine.start()
    }

    public func stop() {
        avEngine.stop()
    }

    public func startTest(totalDuration duration: Double) -> AVAudioPCMBuffer {
        let samples = Int(duration * AKSettings.sampleRate)

        do {
            avEngine.reset()
            try avEngine.enableManualRenderingMode(.offline,
                                                   format: AKSettings.audioFormat,
                                                   maximumFrameCount: maximumFrameCount)
            try start()
        } catch let err {
            AKLog("🛑 Start Test Error: \(err)")
        }

        return AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(samples))!
    }

    public func render(duration: Double) -> AVAudioPCMBuffer {
        let sampleCount = Int(duration * AKSettings.sampleRate)
        let startSampleCount = Int(avEngine.manualRenderingSampleTime)

        let buffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(sampleCount))!

        let tempBuffer = AVAudioPCMBuffer(
            pcmFormat: avEngine.manualRenderingFormat,
            frameCapacity: AVAudioFrameCount(maximumFrameCount))!

        do {
            while avEngine.manualRenderingSampleTime < sampleCount + startSampleCount {
                let currentSampleCount = Int(avEngine.manualRenderingSampleTime)
                let framesToRender = min(UInt32(sampleCount + startSampleCount - currentSampleCount), maximumFrameCount)
                try avEngine.renderOffline(AVAudioFrameCount(framesToRender), to: tempBuffer)
                buffer.append(tempBuffer)
            }
        } catch let err {
            AKLog("🛑 Could not render offline \(err)")
        }
        return buffer
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
            AKDevice(deviceID: id)
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
        try avEngine.render(to: audioFile,
                            maximumFrameCount: maximumFrameCount,
                            duration: duration,
                            prerender: prerender,
                            progress: progress)
    }
}
