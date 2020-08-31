// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import Cocoa

class ViewController: NSViewController {
    @IBOutlet private var frequencyLabel: NSTextField!
    @IBOutlet private var amplitudeLabel: NSTextField!
    @IBOutlet private var noteNameWithSharpsLabel: NSTextField!
    @IBOutlet private var noteNameWithFlatsLabel: NSTextField!
    @IBOutlet private var audioInputPlot: AKNodeOutputPlot!

    lazy var mic = AKMicrophone()
    let mixer = AKMixer()
    var tracker: AKPitchTap!
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
        plot.autoresizingMask = NSView.AutoresizingMask.width
        audioInputPlot.addSubview(plot)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kludge to align sample rates of the graph with the current input sample rate
        AKSettings.sampleRate = AKManager.engine.inputNode.inputFormat(forBus: 0).sampleRate

        AKSettings.audioInputEnabled = true
        mic! >>> mixer
        tracker = AKPitchTap(mixer) { pitch, amp in
            self.updateUI()
        }
        silence = AKBooster(mixer, gain: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        engine.output = silence
        do {
            try engine.start()
            tracker.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
    }
    
    @objc func updateUI() {
        amplitudeLabel.stringValue = String(format: "%0.2f", tracker.amplitude)

        guard tracker.amplitude > 0.1 else { return }

        let trackerFrequency = Float(tracker.leftPitch)

        guard trackerFrequency < 7_000 else {
            // This is a bit of hack because of modern Macbooks giving super high frequencies
            return
        }

        frequencyLabel.stringValue = String(format: "%0.1f", tracker.leftPitch)

        var frequency = trackerFrequency
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10_000.0
        var index = 0

        for i in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[i]) - frequency)
            if distance < minDistance {
                index = i
                minDistance = distance
            }
        }
        let octave = Int(log2f(trackerFrequency / frequency))
        noteNameWithSharpsLabel.stringValue = "\(noteNamesWithSharps[index])\(octave)"
        noteNameWithFlatsLabel.stringValue = "\(noteNamesWithFlats[index])\(octave)"
    }
}
