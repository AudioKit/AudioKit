import AVFoundation
import Utilities

public final class AudioPlayer: Node {
    /// Connected nodes
    public var connections: [Node] { [] }

    // MARK: - Properties
    public var au: AUAudioUnit

    let playerAU: AudioPlayerAudioUnit

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    public var rate: AUValue = 1.0 {
        didSet {
            rate = rate.clamped(to: 0.031_25 ... 32)
            playerAU.rateParam.value = rate
        }
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    public var pitch: AUValue = 0.0 {
        didSet {
            pitch = pitch.clamped(to: -2400 ... 2400)
            playerAU.pitchParam.value = pitch
        }
    }

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    public var overlap: AUValue = 8.0 {
        didSet {
            overlap = overlap.clamped(to: 3 ... 32)
            playerAU.overlapParam.value = overlap
        }
    }

    public init(rate: AUValue = 1.0,
                pitch: AUValue = 0.0,
                overlap: AUValue = 8.0) {
        let componentDescription = AudioComponentDescription(instrument: "apau")

        AUAudioUnit.registerSubclass(AudioPlayerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Audio Player AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        playerAU = au as! AudioPlayerAudioUnit
        self.rate = rate
        self.pitch = pitch
        self.overlap = overlap
    }

    public func play(url: URL) {

        if let file = try? AVAudioFile(forReading: url) {
            playerAU.play(file: file)
        }
    }
}

final class AudioPlayerAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    /// Player AV Audio Node
    public var playerUnit = AVAudioPlayerNode()
    public var timePitch = AVAudioUnitTimePitch()
    private var _engine = AVAudioEngine()

    func play(file: AVAudioFile) {
        playerUnit.play()
        playerUnit.scheduleSegment(file,
                                   startingFrame: 0,
                                   frameCount: AVAudioFrameCount(file.length),
                                   at: .now())
    }

    var stdFormat: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    }

    let rateParam = AUParameterTree.createParameter(identifier: "rate",
                                                    name: "rate",
                                                    address: 0,
                                                    range: 0.031_25 ... 32,
                                                    unit: .generic,
                                                    flags: [])

    let pitchParam = AUParameterTree.createParameter(identifier: "pitch",
                                                    name: "pitch",
                                                    address: 1,
                                                    range: -2400 ... 2400,
                                                    unit: .cents,
                                                    flags: [])

    let overlapParam = AUParameterTree.createParameter(identifier: "overlap",
                                                    name: "overlap",
                                                    address: 2,
                                                    range: 3 ... 32,
                                                    unit: .generic,
                                                    flags: [])

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options)

        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: stdFormat)])

        parameterTree = AUParameterTree.createTree(withChildren: [rateParam, pitchParam, overlapParam])

        let paramBlock = scheduleParameterBlock

        parameterTree?.implementorValueObserver = { parameter, _ in
            paramBlock(.zero, 0, parameter.address, parameter.value)
        }
        setup()
    }

    func setup() {
        _engine.attach(playerUnit)
        _engine.attach(timePitch)

        _engine.connect(playerUnit, to: timePitch, format: stdFormat)
        _engine.connect(timePitch, to: _engine.mainMixerNode, format: stdFormat)

        do {
            try _engine.enableManualRenderingMode(.realtime, format: .init(standardFormatWithSampleRate: 44100, channels: 2)!, maximumFrameCount: 1024)
            try _engine.start()
        } catch {
            print("Could not enable manual rendering mode")
        }

    }

    func processEvents(events: UnsafePointer<AURenderEvent>?) {
        process(events: events,
                param: { event in

                    let paramEvent = event.pointee

                    switch paramEvent.parameterAddress {
                        case 0: timePitch.rate = paramEvent.value
                        case 1: timePitch.pitch = paramEvent.value
                        case 2: timePitch.overlap = paramEvent.value
                        default: break
                    }

                })
    }


    override var internalRenderBlock: AUInternalRenderBlock {
        { (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           _: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           _: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           _: AURenderPullInputBlock?) in

            self.processEvents(events: renderEvents)

            var status = noErr
            _ = self._engine.manualRenderingBlock(frameCount, outputBufferList, &status)
            return status
        }
    }
}
