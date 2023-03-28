import AVFoundation

final class AudioPlayerAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    /// Player AV Audio Node
    public var playerUnit = AVAudioPlayerNode()
    public var timePitch = AVAudioUnitTimePitch()
    private var _engine = AVAudioEngine()

    var loopStart: TimeInterval = 0.0
    var loopDuration: TimeInterval = 0.0
    public  var isLooping: Bool = false

    private var file: AVAudioFile?

    func play() {
        scheduleSegment()
        playerUnit.play()
    }

    func stop() {
        playerUnit.stop()
    }

    func load(file: AVAudioFile) {
        self.file = file
        loopDuration = file.duration
    }

    func scheduleSegment() {
        if let file {

            let length = min(file.duration, loopDuration)

            let frameCount = AVAudioFrameCount(length * 44100)

            if frameCount <= 0 || loopStart < 0 {
                return
            }

            playerUnit.scheduleSegment(file,
                                       startingFrame: AVAudioFramePosition(loopStart * 44100),
                                       frameCount: frameCount,
                                       at: .now()) {
                if self.isLooping {
                    self.scheduleSegment()
                }
            }
            playerUnit.prepare(withFrameCount: frameCount)
        }
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
}
