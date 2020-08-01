// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation

/// Audio player that loads a sample into memory
open class AKSequencerTrack: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKSequencerEngineAudioUnit

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "sqcr")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?
    public var targetNode: AKNode?

    /// Length of the track in beats
    public var length: Double {
        get { return Double(internalAU?.length.value ?? 0) }
        set { internalAU?.length.value = AUValue(newValue) }
    }

    /// Speed of the track in beats per minute
    public var tempo: BPM {
        get { return BPM(internalAU?.tempo.value ?? 0) }
        set { internalAU?.tempo.value = AUValue(newValue) }
    }

    /// Maximum number of times to play, ie. loop the track
    public var maximumPlayCount: Double {
        get { return Double(internalAU?.maximumPlayCount.value ?? 0) }
        set { internalAU?.maximumPlayCount.value = AUValue(newValue) }
    }

    /// Is looping enabled?
    public var loopEnabled: Bool {
        set { internalAU?.loopEnabled.value = newValue ? 1 : 0 }
        get { return (internalAU?.loopEnabled.value ?? 0) > 0.5 }
    }

    /// Is the track currently playing?
    public var isPlaying: Bool {
        return internalAU?.isStarted ?? false
    }

    /// Current position of the track
    public var currentPosition: Double {
        return Double(internalAU?.position.value ?? 0)
    }

    // MARK: - Initialization

    /// Initialize the track
    public init(targetNode: AKNode?) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        AKManager.internalConnections.append(self)
        if let target = targetNode {
            setTarget(node: target)
        }
    }

    /// Set the target node
    public func setTarget(node: AKNode) {
        targetNode = node

        guard let audioUnit = targetNode?.avAudioUnit?.audioUnit else {
            AKLog("Failed to setTarget")
            return
        }
        internalAU?.setTarget(audioUnit)
    }

    /// Start the track
    public func play() {
        internalAU?.start()
    }

    /// Start the track from the beginning
    public func playFromStart() {
        seek(to: 0)
        internalAU?.start()
    }

    /// Start the track after a certain delay in beats
    public func playAfterDelay(beats: Double) {
        seek(to: -1 * beats)
        internalAU?.start()
    }

    /// Stop playback
    public func stop() {
        internalAU?.stop()
    }

    /// Set the current position to the start ofthe track
    public func rewind() {
        internalAU?.position.value = 0
    }

    /// Move to a position in the track
    public func seek(to position: Double) {
        internalAU?.position.value = AUValue(position)
    }

    public var sequence = AKSequence() {
        didSet {
            internalAU?.update(sequence: sequence)
        }
    }

    /// Remove the notes in the track
    public func clear() {
        sequence = AKSequence()
    }

    /// Stop playing all the notes current in the "now playing" array.
    public func stopPlayingNotes() {
        internalAU?.stopPlayingNotes()
    }
}

#endif
