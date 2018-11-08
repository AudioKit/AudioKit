// MARK: - Instrument Player
/*
 This class implements a basic player for our instrument sample au,
 sending a whole tone scale on a concurrent thread until stopped.
 */
import AVFoundation
import Cocoa

public class InstrumentPlayer: NSObject {
    private let playingQueue = DispatchQueue(label: "InstrumentPlayer.playingQueue")

    private var noteBlock: AUScheduleMIDIEventBlock

    private var _isPlaying: Bool = false

    public var isPlaying: Bool {
        get {
            var result = false
            playingQueue.sync {
                result = self._isPlaying
            }
            return result
        }

        set {
            self.playingQueue.sync {
                self._isPlaying = newValue
            }
        }
    }

    internal init?(audioUnit: AUAudioUnit?) {
        guard let audioUnit = audioUnit else { return nil }
        guard let theNoteBlock = audioUnit.scheduleMIDIEventBlock else { return nil }

        self.noteBlock = theNoteBlock
        super.init()
    }

    internal func play() {
        if !self.isPlaying {
            self.scheduleInstrumentLoop()
        }
    }

    func stop() {
        self.isPlaying = false
    }

    private func scheduleInstrumentLoop() {
        self.isPlaying = true

        let cbytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)

        DispatchQueue.global(qos: .default).async {
            cbytes[0] = 0xB0
            cbytes[1] = 123
            cbytes[2] = 0
            self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

            usleep(useconds_t(0.1 * 1e6))
            var releaseTime: Float = 0.05
            usleep(useconds_t(0.1 * 1e6))

            var i = 0
            while self.isPlaying {
                // lengthen the releaseTime by 5% each time up to 10 seconds.
                if releaseTime < 10.0 {
                    releaseTime = min(releaseTime * 1.05, 10.0)
                }

                cbytes[0] = 0x90
                cbytes[1] = UInt8(60 + i)
                cbytes[2] = 64
                self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

                usleep(useconds_t(0.2 * 1e6))

                cbytes[2] = 0 // note off
                self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

                i += 2
                if i >= 24 {
                    i = -12
                }
            } // while isPlaying

            cbytes[0] = 0xB0
            cbytes[1] = 123
            cbytes[2] = 0
            self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

            cbytes.deallocate()

        } // dispached
    } // scheduleInstrumentLoop
}
