// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFoundation
import Utilities

class SamplerKernel {

    /// A potential sample for every MIDI note.
    private var samples = [UnsafeMutablePointer<SampleHolder>?](repeating: nil, count: 128)

    /// Voices for playing back samples.
    private var voices = [SamplerVoice](repeating: SamplerVoice(), count: 1024)

    /// Returns an available voice. Audio thread ONLY.
    func getVoice() -> Int? {
        // Linear search to find a voice. This could be better
        // using a free list but we're lazy.
        for index in 0 ..< voices.count {
            if !voices[index].inUse {
                voices[index].inUse = true
                return index
            }
        }

        // No voices available.
        return nil
    }

    func startVoice(holderPtr ptr: UnsafeMutablePointer<SampleHolder>) {
        if let voiceIndex = self.getVoice() {
            self.voices[voiceIndex].sample = ptr

            self.voices[voiceIndex].sampleFrames = Int(ptr.pointee.frameLength)
            self.voices[voiceIndex].playhead = 0
        }
    }

    func processMIDI(event: UnsafePointer<AUMIDIEvent>) {
        let data = event.pointee.data
        let command = data.0 & 0xF0
        let noteNumber = data.1
        if command == noteOnByte {
            if let ptr = self.samples[Int(noteNumber)] {
                startVoice(holderPtr: ptr)
            }
        } else if command == noteOffByte {
            // XXX: ignore for now
        }
    }

    func processSysex(event: UnsafePointer<AUMIDIEvent>) {

        var command: SamplerCommand = .stop

        decodeSysex(event, &command)

        switch command {
        case let .playSample(ptr):
            startVoice(holderPtr: ptr)

        case let .assignSample(ptr, noteNumber):
            self.samples[Int(noteNumber)] = ptr
        case .stop:
            for index in 0 ..< self.voices.count {
                self.voices[index].inUse = false
            }
        }

    }

    func processEvents(events: UnsafePointer<AURenderEvent>?) {
        process(events: events, midi: processMIDI, sysex: processSysex)
    }

    func render(frameCount: AUAudioFrameCount, outputBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus {

        let outputBufferListPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

        // Clear output.
        for channel in 0 ..< outputBufferListPointer.count {
            outputBufferListPointer[channel].clear()
        }

        // Render all active voices to output.
        for voiceIndex in self.voices.indices {
            self.voices[voiceIndex].render(to: outputBufferListPointer, frameCount: frameCount)
        }

        return noErr
    }
}
