// MARK: - Instrument Player - from Apple
/*
	This class implements a basic player for our instrument sample au,
 sending some fake MIDI events on a concurrent thread until stopped.
 */
import Cocoa
import AVFoundation

public class InstrumentPlayer: NSObject {
    public var isPlaying = false
    private var isDone = false
    private var noteBlock: AUScheduleMIDIEventBlock

    internal init?(audioUnit: AUAudioUnit?) {
        guard audioUnit != nil else { return nil }
        guard let theNoteBlock = audioUnit!.scheduleMIDIEventBlock else { return nil }

        noteBlock = theNoteBlock
        super.init()
    }

    internal func play() {
        if (false == isPlaying) {
            isDone = false
            scheduleInstrumentLoop()
        }
    }

    @discardableResult
    internal func stop() -> Bool {
        self.isPlaying = false
        synced(self.isDone as AnyObject) {}
        return isDone
    }

    private func synced(_ lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    private func scheduleInstrumentLoop() {
        isPlaying = true

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
            self.synced(self.isDone as AnyObject) {
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

                    cbytes[2] = 0    // note off
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

                cbytes.deallocate(capacity: 3)

                self.isDone = true
            } // synced
        } // dispached
    } // scheduleInstrumentLoop
}
