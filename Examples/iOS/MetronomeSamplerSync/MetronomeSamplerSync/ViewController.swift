//
//  ViewController.swift
//  MetronomeSamplerSync
//
//  Created by David O'Neill, revision history on Githbub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKitUI
import AudioKit

// This Example is to demonstrate how to syncronize the AKSamplerMetronome using AVAudioTime.

class ViewController: UIViewController {
    var metronome1 = AKSamplerMetronome()
    var metronome2 = AKSamplerMetronome()
    var mixer = AKMixer()
    var views = [UIView]()
    var tapTempo = TapTempo(timeOut: 2.0, minimumTaps: 3)
    let tempoSlider = AKSlider(property: "Tempo")

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let oneSoundUrl = Bundle.main.url(forResource: "cheeb-ch", withExtension: "wav"),
            let countSoundUrl = Bundle.main.url(forResource: "closed_hi_hat_F#1", withExtension: "wav") else {
                fatalError()
        }
        metronome1.sound = countSoundUrl
        metronome1.downBeatSound = oneSoundUrl

        metronome1 >>> mixer
        metronome2 >>> mixer
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setUpUI()
    }

    @objc func beatsSelected(segmentedControl: UISegmentedControl) {
        let beatCount = Int32(segmentedControl.selectedSegmentIndex + 1)
        let now = AVAudioTime(hostTime: mach_absolute_time())
        metronome1.setBeatCount(beatCount, at: now)
        metronome2.setBeatCount(beatCount, at: now)
    }

    func beatsSlider(slider: UISlider) {
        let beatCount = Int32(1 + slider.value * 7)

        if metronome1.beatCount != beatCount {
            let now = AVAudioTime(hostTime: mach_absolute_time())
            metronome1.setBeatCount(beatCount, at: now)
            metronome2.setBeatCount(beatCount, at: now)
        }
    }

    func setUpUI() {

        func startStopAction(met: AKSamplerMetronome, otherMet: AKSamplerMetronome) -> (AKButton) -> Void {
            return { button in
                // Stop if playing, Start if not playing.
                if met.isPlaying {
                    met.stop()
                } else {
                    //If other metronome is playing, sync to it, else just play.
                    if otherMet.isPlaying {
                        let now = AVAudioTime(hostTime: mach_absolute_time())
                        let beatAtNow = otherMet.beatTime(at: now)
                        met.setBeatTime(beatAtNow, at: now)
                    } else {
                        met.beatTime = 0
                        met.play()
                    }
                }
                button.title = met.isPlaying ? "Stop" : "Play"
            }
        }

        func tapTempoAction(met: AKSamplerMetronome, otherMet: AKSamplerMetronome) -> (AKButton) -> Void {
            return { [weak self] button in
                guard let newTempo = self?.tapTempo.addTap() else { return }
                let now = AVAudioTime(hostTime: mach_absolute_time())
                otherMet.setTempo(newTempo, at: now)
                met.setTempo(newTempo, at: now)
                self?.tempoSlider.value = newTempo
            }
        }

        addView(AKButton(title: "Play",
                         callback: startStopAction(met: metronome1, otherMet: metronome2)))

        addView(AKButton(title: "Play",
                         callback: startStopAction(met: metronome2, otherMet: metronome1)))

        addView(tempoSlider)
        tempoSlider.callback = { [weak self] tempo in

            let now = AVAudioTime(hostTime: mach_absolute_time())
            self?.metronome1.setTempo(tempo, at: now)
            self?.metronome2.setTempo(tempo, at: now)

        }
        tempoSlider.range = 30 ... 4_000
        tempoSlider.taper = 1
        tempoSlider.format = "%0.0f"
        tempoSlider.color = .blue
        tempoSlider.frame = CGRect()
        tempoSlider.value = metronome1.tempo

        addView(AKSlider(property: "Down Beat Volume",
                         value: 1.0,
                         range: 0...1,
                         taper: 1,
                         format: "%0.1f",
                         color: .blue,
                         frame: CGRect(),
                         callback: { [weak self] volume in

                            self?.metronome1.downBeatVolume = Float(volume)
                            self?.metronome2.downBeatVolume = Float(volume)

        }))

        addView(AKSlider(property: "Beat Volume",
                         value: 1.0,
                         range: 0...1,
                         taper: 1,
                         format: "%0.1f",
                         color: .blue,
                         frame: CGRect(),
                         callback: { [weak self] volume in

                            self?.metronome1.beatVolume = Float(volume)
                            self?.metronome2.beatVolume = Float(volume)

        }))

        let beatsSelector = UISegmentedControl(items: Array(1...8).map { String($0) })
        beatsSelector.addTarget(self, action: #selector(beatsSelected(segmentedControl:)), for: .valueChanged)
        beatsSelector.selectedSegmentIndex = 3
        addView(beatsSelector)

        addView(AKButton(title: "Tap Tempo (3x)",
                         callback: tapTempoAction(met: metronome2, otherMet: metronome1)))

    }
    func addView(_ view: UIView) {
        views.append(view)
        self.view.addSubview(view)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset = CGFloat(10)
        let elemHeight = CGFloat(80)

        var nextFrame = CGRect(x: inset,
                               y: (view.frame.size.height - (elemHeight) * CGFloat(view.subviews.count)) / 2.0,
                               width: view.frame.size.width - inset * 2,
                               height: elemHeight)

        for view in views {
            view.frame = nextFrame
            AKLog("frame " + String(describing: nextFrame.origin.y))
            nextFrame = nextFrame.offsetBy(dx: 0, dy: nextFrame.size.height + inset)
        }
    }
}
