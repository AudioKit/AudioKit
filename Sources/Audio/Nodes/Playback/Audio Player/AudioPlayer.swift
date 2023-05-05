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
            playerAU.timePitch.rate = rate
        }
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    public var pitch: AUValue = 0.0 {
        didSet {
            pitch = pitch.clamped(to: -2400 ... 2400)
            playerAU.timePitch.pitch = pitch
        }
    }

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    public var overlap: AUValue = 8.0 {
        didSet {
            overlap = overlap.clamped(to: 3 ... 32)
            playerAU.timePitch.overlap = overlap
        }
    }

    public var loopStart: AUValue = 0.0 {
        didSet {
            playerAU.loopStart = TimeInterval(loopStart)
        }
    }

    public var loopDuration: AUValue = 0.0 {
        didSet {
            playerAU.loopDuration = TimeInterval(loopDuration)
        }
    }

    public var isLooping: Bool = false {
        didSet {
            playerAU.isLooping = isLooping
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

        Engine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        Engine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }

    public func play(url: URL) {
        load(url: url)
        play()
    }

    public func load(url: URL) {
        if let file = try? AVAudioFile(forReading: url) {
            playerAU.load(file: file)
        }
    }

    public func stop() {
        playerAU.stop()
    }

    public func play() {
        playerAU.stop()
        playerAU.play()
    }


}

