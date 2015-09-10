//
//  AnalysisViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class AnalysisViewController: NSViewController {

    @IBOutlet var frequencyLabel: NSTextField!
    @IBOutlet var amplitudeLabel: NSTextField!
    @IBOutlet var noteNameWithSharpsLabel: NSTextField!
    @IBOutlet var noteNameWithFlatsLabel: NSTextField!

    var analyzer: AKAudioAnalyzer!
    let microphone = AKMicrophone()

    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]

    let analysisSequence = AKSequence()
    var updateAnalysis: AKEvent?

    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.shared().audioInputEnabled = true

        analyzer = AKAudioAnalyzer(input: microphone.output)

        AKOrchestra.addInstrument(microphone)
        AKOrchestra.addInstrument(analyzer)
        analyzer.play()
        microphone.play()

        let analysisSequence = AKSequence()
        updateAnalysis = AKEvent {
            self.updateUI()
            analysisSequence.addEvent(self.updateAnalysis, afterDuration: 0.1)
        }
        analysisSequence.addEvent(updateAnalysis)
        analysisSequence.play()
    }

    func updateUI() {
        if (analyzer.trackedAmplitude.floatValue > 0.1) {
            frequencyLabel.stringValue = String(format: "%0.1f", analyzer.trackedFrequency.floatValue)

            var frequency = analyzer.trackedFrequency.floatValue
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            var minDistance: Float = 10000.0
            var index = 0

            for (var i = 0; i < noteFrequencies.count; i++) {

                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if (distance < minDistance){
                    index = i
                    minDistance = distance
                }
            }

            let octave = Int(log2f(analyzer.trackedFrequency.floatValue / frequency))
            var noteName = String(format: "%@%d", noteNamesWithSharps[index], octave)
            noteNameWithSharpsLabel.stringValue = noteName
            noteName = String(format: "%@%d", noteNamesWithFlats[index], octave)
            noteNameWithFlatsLabel.stringValue = noteName
        }
        amplitudeLabel.stringValue = String(format: "%0.2f", analyzer.trackedAmplitude.floatValue)
    }
}
