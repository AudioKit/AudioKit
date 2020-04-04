//
//  AKDynamicPlayer.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

public class AKDynamicPlayer: AKPlayer {
    /// The time pitch node - disabled by default
    public private(set) var timePitchNode: AKTimePitch?

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0 and disabled)
    public var rate: Double {
        get {
            return timePitchNode?.rate ?? 1
        }

        set {
            if newValue == rate {
                return
            }

            // timePitch is only installed if it is requested. This saves resources.
            if timePitchNode != nil, newValue == 1, pitch == 0 {
                removeTimePitch()
                return
            } else if timePitchNode == nil, newValue != 1 {
                createTimePitch()
            }

            if let timePitchNode = self.timePitchNode {
                timePitchNode.rate = newValue
                if timePitchNode.isBypassed, timePitchNode.rate != 1 {
                    timePitchNode.start()
                }
            }
        }
    }

    // override this with the actual rate property above
    internal override var _rate: Double {
        return rate
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0 and disabled)
    public var pitch: Double {
        get {
            return timePitchNode?.pitch ?? 0
        }

        set {
            if newValue == pitch {
                return
            }
            // timePitch is only installed if it is requested. This saves nodes as it's expensive.
            if timePitchNode != nil, newValue == 0, rate == 1, !isPlaying {
                removeTimePitch()
                return
            } else if timePitchNode == nil, newValue != 0 {
                createTimePitch()
            }

            if let timePitchNode = self.timePitchNode {
                timePitchNode.pitch = newValue
                if timePitchNode.isBypassed, timePitchNode.pitch != 0 {
                    timePitchNode.start()
                }
            }
        }
    }

    // MARK: - Initialization

    open override func initialize(restartIfPlaying: Bool = true) {
        if let timePitchNode = self.timePitchNode {
            if timePitchNode.avAudioNode.engine == nil {
                AudioKit.engine.attach(timePitchNode.avAudioNode)
            } else {
                timePitchNode.disconnectOutput()
            }
        }
        super.initialize(restartIfPlaying: restartIfPlaying)
    }

    internal override func connectNodes() {
        guard let processingFormat = processingFormat else {
            AKLog("Error: the audioFile processingFormat is nil, so nothing can be connected.")
            return
        }

        var connectionFormat = processingFormat
        var playerOutput: AVAudioNode = playerNode

        // if there is a mixer that was creating, insert it in line
        // this is used only for dynamic sample rate conversion to
        // AKSettings.audioFormat if needed
        if let mixerNode = mixerNode {
            AudioKit.connect(playerNode, to: mixerNode, format: processingFormat)
            connectionFormat = AKSettings.audioFormat
            playerOutput = mixerNode
        }

        if let faderNode = faderNode, let timePitchNode = timePitchNode {
            AKLog("👉 Player → Time Pitch → Fader using", connectionFormat)
            AudioKit.connect(playerOutput, to: timePitchNode.avAudioNode, format: connectionFormat)
            AudioKit.connect(timePitchNode.avAudioUnitOrNode, to: faderNode.avAudioUnitOrNode, format: connectionFormat)
            timePitchNode.bypass()

        } else if let faderNode = super.faderNode {
            AKLog("👉 Player → Fader using", connectionFormat)
            AudioKit.connect(playerOutput, to: faderNode.avAudioUnitOrNode, format: connectionFormat)
        }
    }

    public func createTimePitch() {
        guard timePitchNode == nil else { return }

        AKLog("👉 Creating AKTimePitch")
        timePitchNode = AKTimePitch()
        initialize()
    }

    // Removes the Time / Pitch AU from the signal chain
    public func removeTimePitch() {
        guard timePitchNode != nil else { return }
        let wasPlaying = isPlaying
        stop()
        timePitchNode?.disconnectOutput()
        timePitchNode?.detach()
        timePitchNode = nil
        initialize()
        if wasPlaying {
            play()
        }
    }

    public override func play(from startingTime: Double, to endingTime: Double, at audioTime: AVAudioTime?, hostTime: UInt64?) {
        timePitchNode?.start()
        super.play(from: startingTime, to: endingTime, at: audioTime, hostTime: hostTime)
    }

    /// Stop playback and cancel any pending scheduled playback or completion events
    public override func stop() {
        super.stop()

        // the time strecher draws a fair bit of CPU when it isn't bypassed, so auto bypass it
        timePitchNode?.bypass()
    }

    /// Dispose the audio file, buffer and nodes and release resources.
    /// Only call when you are totally done with this class.
    public override func detach() {
        super.detach()
        timePitchNode?.detach()
    }
}
