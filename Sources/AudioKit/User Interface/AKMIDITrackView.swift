// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if targetEnvironment(macCatalyst) || os(iOS)
import Foundation
import UIKit

/*
This file contains the code for a horizontal MIDI sequencer view, similar to what you see
in most Digital Audio Workstations.
To add this view to your app, it's as simple as specifying the size/position of the view you
would like, giving it a MIDI File URL and track number, adding an AKMIDISampler,
adding an AKAppleSequencer,
 and adding the track view to the view controller

For example:

var trackView1: AKMIDITrackView = AKMIDITrackView(frame: CGRect(x: , y: , width: , height: ),
midiFile: AKMIDIFile(url: urltoyourmidifile),
trackNumber: The MIDI track number you want to display,
 sampler: AKMIDISampler,
 sequencer: AKAppleSequencer)

//Inside View Controller

self.view.addSubview(self.trackView1)

self.trackView1.play()

If you are using an AKAppleSampler or AKSampler, sequencer, etc,
you will want to play the track directly before you play through the sequencer
so the sound is synced with the playback.

This file is still in development. I have tried loading some forms of MIDI files, and they do not yet work.
I have recently set up the playback to be synced with automated tempos which change over time.
*/

//Display a MIDI Sequence in a track

public class AKMIDITrackView: AKButton {
 //Quarter note at 120 bpm is 20.8333... pixels - standard
    var length: Double!
    var playbackCursorRect: CGRect!
    var playbackCursorView: UIView!
    var collectiveNoteView: UIView!
    var cursorTimer: Timer!
    var scrollTimer: Timer!
    var readyToPlay: Bool = false
    var playbackCursorPosition: Double = 0.0
    var noteGroupPosition: Double = 0.0
    public var midiTrackNoteMap: AKMIDIFileTrackNoteMap!
    public var sampler: AKMIDISampler!
    public var sequencer: AKAppleSequencer!
    var previousTempo = 0.0
    var trackLength: Double {
        return midiTrackNoteMap.endOfTrack
    }

    //How far the view is zoomed in
    public var noteZoomConstant: Double = 10_000.0

    /// Initialize the Track View
    public convenience init(frame: CGRect, midiFile: URL!,
                            trackNumber: Int,
                            sampler: AKMIDISampler,
                            sequencer: AKAppleSequencer) {
        self.init(frame: frame)
        self.borderWidth = 0.0
        clipsToBounds = true
        self.sampler = sampler
        self.sequencer = sequencer
        self.midiTrackNoteMap = AKMIDIFileTrackNoteMap(midiFile: AKMIDIFile(url: midiFile), trackNum: trackNumber)
        populateViewNotes()
    }

    /// Default init from superclass
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderWidth = 0.0
        clipsToBounds = true
    }

    /// Initialization within Interface Builder
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.borderWidth = 0.0
        clipsToBounds = true
    }

    //Cursor which displays for the first few seconds of the midi clip until it goes out of bounds
    public func play() {
        playbackCursorRect = CGRect(x: 0, y: 0, width: 3, height: Double(self.frame.height))
        playbackCursorView = UIView(frame: playbackCursorRect)
        playbackCursorView.backgroundColor = .white
        collectiveNoteView.addSubview(self.playbackCursorView)
        if self.sequencer.allTempoEvents.count == 1 {
            sequencer.setTempo(self.sequencer.allTempoEvents[0].1)
            previousTempo = self.sequencer.allTempoEvents[0].1
            let tempo = self.sequencer.allTempoEvents[0].1
            cursorTimer = Timer.scheduledTimer(timeInterval: (1.0 / ((20 + (8.0 / 10.0) + (1.0 / 30.0)))) *
                                               (1.0 / tempo) * 60.0,
            target: self,
            selector: #selector(self.updateCursor),
            userInfo: nil,
            repeats: true)
        } else {
            cursorTimer = Timer.scheduledTimer(timeInterval: (1.0 / ((20 + (8.0 / 10.0) + (1.0 / 30.0)))) *
                                                (1.0 / sequencer.tempo) * 60.0,
            target: self,
            selector: #selector(self.updateCursor),
            userInfo: nil,
            repeats: true)
        }
    }
    public func stop() {
        if let ctimer = cursorTimer {
            ctimer.invalidate()
        }
        if let stimer = scrollTimer {
            stimer.invalidate()
        }
        sequencer.stop()
    }

    public func populateViewNotes() {

        let noteDescriptor = midiTrackNoteMap
        var noteRange = 0
        var noteList: [AKMIDINoteDuration] = [AKMIDINoteDuration]()
        if let noteR = noteDescriptor?.noteRange {
            noteRange = noteR
        }
        if let noteL = noteDescriptor?.noteList {
            noteList = noteL
        }

        let trackHeight = Double(self.frame.size.height)

        let noteHeight = trackHeight / Double(noteRange)
        let maxHeight = Double(trackHeight - (noteHeight))

        let loNote = midiTrackNoteMap.loNote

        let zoomConstant = noteZoomConstant
        length = trackLength * zoomConstant

        //Create invisible scroll view which moves all the notes
        let collectiveNoteViewRect = CGRect(x: 0, y: 0, width: trackLength * noteZoomConstant, height: trackHeight)
        collectiveNoteView = UIView(frame: collectiveNoteViewRect)
        noteGroupPosition = Double(collectiveNoteViewRect.origin.x)
        self.addSubview(collectiveNoteView)
        for note in noteList {
            let noteNum = note.noteNum - loNote
            let noteStart = Double(note.noteBeginningTime)
            let noteDuration = Double(note.noteDuration)
            let noteLength = Double(noteDuration * zoomConstant)
            let notePosition = Double(noteStart * zoomConstant)
            let noteLevel = (maxHeight - (Double(noteNum) * noteHeight))
            let singleNoteRect = CGRect(x: notePosition, y: noteLevel, width: noteLength, height: noteHeight)
            let singleNoteView = UIView(frame: singleNoteRect)
            singleNoteView.backgroundColor = self.highlightedColor
            collectiveNoteView.addSubview(singleNoteView)
        }

        readyToPlay = true
    }

    //Move the playback cursor across the screen
    @objc func updateCursor() {
        if previousTempo != sequencer.tempo {
            previousTempo = sequencer.tempo
            cursorTimer.invalidate()
            cursorTimer = Timer.scheduledTimer(timeInterval: (1.0 / ((20 + (8.0 / 10.0) + (1.0 / 30.0)))) *
                                                (1.0 / sequencer.tempo) * 60.0,
            target: self,
            selector: #selector(self.updateCursor),
            userInfo: nil,
            repeats: true)
        }
        let width = Double(self.frame.size.width)
        playbackCursorPosition += 1
        if Double(self.playbackCursorView.frame.origin.x) < (width - 20) {
            playbackCursorRect = CGRect(x: playbackCursorPosition, y: 0, width: 3, height: Double(self.frame.height))
            playbackCursorView.frame = playbackCursorRect
        } else {
            playbackCursorView.removeFromSuperview()
            cursorTimer.invalidate()
            scrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / ((20 + (8.0 / 10.0) + (1.0 / 30.0)))) *
                                                (1.0 / sequencer.tempo) * 60.0,
            target: self,
            selector: #selector(self.scrollNotes),
            userInfo: nil,
            repeats: true)
        }
        if !sequencer.isPlaying && readyToPlay {
            sequencer.play()
        }
    }

 //Move the note view across the screen
    @objc func scrollNotes() {
        if previousTempo != sequencer.tempo {
            previousTempo = sequencer.tempo
            scrollTimer.invalidate()
            scrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / ((20 + (8.0 / 10.0) + (1.0 / 30.0)))) *
                                                (1.0 / sequencer.tempo) * 60.0,
            target: self,
            selector: #selector(self.scrollNotes),
            userInfo: nil,
            repeats: true)
        }
        noteGroupPosition -= 1
        collectiveNoteView.frame.origin.x = CGFloat(noteGroupPosition)
    }
}

#endif
