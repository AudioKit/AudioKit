import AVFoundation
import Utilities

public final class AudioPlayer: Node {
    /// Connected nodes
    public var connections: [Node] { [] }

    // MARK: - Properties
    public var au: AUAudioUnit

    let playerAU: AudioPlayerAudioUnit

    public init() {
        let componentDescription = AudioComponentDescription(instrument: "apau")

        AUAudioUnit.registerSubclass(AudioPlayerAudioUnit.self,
                                     as: componentDescription,
                                     name: "Audio Player AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        playerAU = au as! AudioPlayerAudioUnit
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
        timePitch.rate = 0.5
        playerUnit.play()
        playerUnit.scheduleSegment(file,
                                   startingFrame: 0,
                                   frameCount: AVAudioFrameCount(file.length),
                                   at: .now())
    }

    var stdFormat: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
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

        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: stdFormat)])

        parameterTree = AUParameterTree.createTree(withChildren: [])
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

    override var internalRenderBlock: AUInternalRenderBlock {
        { (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           _: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           _: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           _: AURenderPullInputBlock?) in
            var status = noErr
            _ = self._engine.manualRenderingBlock(frameCount, outputBufferList, &status)
            return status
        }
    }

//    static func avRenderBlock(block: @escaping AVAudioEngineManualRenderingBlock) -> AUInternalRenderBlock {
//        {
//            (_: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//             _: UnsafePointer<AudioTimeStamp>,
//             frameCount: AUAudioFrameCount,
//             _: Int,
//             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
//             _: AURenderPullInputBlock?)  in
//
//            var status = noErr
//            _ = block(frameCount, outputBufferList, &status)
//
//            return status
//        }
//    }
}
