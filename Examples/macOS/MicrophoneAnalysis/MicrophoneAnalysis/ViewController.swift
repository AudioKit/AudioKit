//
//  ViewController.swift
//  MicrophoneAnalysis
//
//  Created by Kanstantsin Linou on 6/14/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    @IBOutlet private var frequencyLabel: NSTextField!
    @IBOutlet private var amplitudeLabel: NSTextField!
    @IBOutlet private var noteNameWithSharpsLabel: NSTextField!
    @IBOutlet private var noteNameWithFlatsLabel: NSTextField!
    @IBOutlet private var audioInputPlot: EZAudioPlot!

    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = NSColor.blue
        plot.autoresizingMask = .viewWidthSizable
        audioInputPlot.addSubview(plot)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.stringValue = String(format: "%0.1f", tracker.frequency)

            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.stringValue = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.stringValue = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.stringValue = String(format: "%0.2f", tracker.amplitude)
    }
}
