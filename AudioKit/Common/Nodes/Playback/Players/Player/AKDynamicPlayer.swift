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
    public override var rate: Double {
        get {
            return timePitchNode?.rate ?? 1
        }

        set {
            if newValue == rate {
                return
            }

            // timePitch is only installed if it is requested. This saves resources.
            if timePitchNode != nil && newValue == 1 {
                removeTimePitch()
                return
            } else if timePitchNode == nil && newValue != 1 {
                timePitchNode = AKTimePitch()
                initialize()
            }

            guard let timePitchNode = timePitchNode else { return }
            timePitchNode.rate = newValue
            if timePitchNode.isBypassed && timePitchNode.rate != 1 {
                timePitchNode.start()
            }
        }
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
            // timePitch is only installed if it is requested. This saves resources.
            if timePitchNode != nil && newValue == 0 {
                removeTimePitch()
                return
            } else if timePitchNode == nil && newValue != 0 {
                timePitchNode = AKTimePitch()
                initialize()
            }

            guard let timePitchNode = timePitchNode else { return }
            timePitchNode.pitch = newValue
            if timePitchNode.isBypassed && timePitchNode.pitch != 0 {
                timePitchNode.start()
            }
        }
    }

    // MARK: - Initialization

    internal override func initialize() {
        if let timePitchNode = timePitchNode {
            if timePitchNode.avAudioNode.engine == nil {
                AudioKit.engine.attach(timePitchNode.avAudioNode)
            } else {
                timePitchNode.disconnectOutput()
            }
        }

        super.initialize()
    }

    internal override func connectNodes() {
        guard let processingFormat = processingFormat else { return }

        if let timePitchNode = timePitchNode, let faderNode = faderNode {
            AudioKit.connect(playerNode, to: timePitchNode.avAudioNode, format: processingFormat)
            AudioKit.connect(timePitchNode.avAudioNode, to: faderNode.avAudioNode, format: processingFormat)
            AudioKit.connect(faderNode.avAudioNode, to: mixer, format: processingFormat)
            timePitchNode.bypass() // bypass timePitch by default to save CPU
            AKLog(audioFile?.url.lastPathComponent ?? "URL is nil", processingFormat, "Connecting timePitch and fader")

        } else if let timePitchNode = timePitchNode, faderNode == nil {
            AudioKit.connect(playerNode, to: timePitchNode.avAudioNode, format: processingFormat)
            AudioKit.connect(timePitchNode.avAudioNode, to: mixer, format: processingFormat)
            timePitchNode.bypass()
            AKLog(audioFile?.url.lastPathComponent ?? "URL is nil", processingFormat, "Connecting timePitch")

        } else if let faderNode = faderNode {
            // if the timePitchNode isn't created connect the player directly to the faderNode
            AudioKit.connect(playerNode, to: faderNode.avAudioNode, format: processingFormat)
            AudioKit.connect(faderNode.avAudioNode, to: mixer, format: processingFormat)
            AKLog(audioFile?.url.lastPathComponent ?? "URL is nil", processingFormat, "Connecting fader")

        } else {
            AudioKit.connect(playerNode, to: mixer, format: processingFormat)
            AKLog(audioFile?.url.lastPathComponent ?? "URL is nil", processingFormat, "Connecting player to mixer")
        }
    }

    private func removeTimePitch() {
        guard let timePitchNode = timePitchNode else { return }
        stop()
        timePitchNode.disconnectOutput()
        AudioKit.detach(nodes: [timePitchNode.avAudioNode])
        self.timePitchNode = nil
        initialize()
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

    public override func detach() {
        super.detach()
        if let timePitchNode = timePitchNode {
            AudioKit.detach(nodes: [timePitchNode.avAudioNode])
        }
    }
}
