//
//  ViewController.swift
//  iOSDevelopment
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var sliderLabel1: UILabel!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var sliderLabel2: UILabel!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var outputTextView: UITextView!

    // Define components
    var oscillator = AKOscillator()
    var booster = AKBooster()
    var player: AKPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        sliderLabel1.text = "Gain"
        sliderLabel2.text = "Ramp Time"
        button1.titleLabel?.text = "Start"
    }

    @IBAction func start(_ sender: UIButton) {

        if let audioFile = try? AKAudioFile(readFileName: "Organ.wav", baseDir: .resources) {
            let player = AKPlayer(audioFile: audioFile)
            player.isLooping = true
            player >>> booster
            self.player = player
        }

        //oscillator >>> booster
        booster.gain = 1

        AudioKit.output = booster
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        sender.isEnabled = false

    }

    @IBAction func button1(_ sender: UIButton) {
        guard let player = player else { return }
        guard let url = player.audioFile?.url.lastPathComponent else { return }
        if player.isPlaying {
            player.stop()
            button1.titleLabel?.text = "Start"
            updateText("Stopped")
        } else {
            player.play()
            button1.titleLabel?.text = "Stop"
            updateText("Playing \(url)")
        }

//        if oscillator.isPlaying {
//            oscillator.stop()
//            button1.titleLabel?.text = "Start"
//            updateText("Stopped")
//        } else {
//            oscillator.start()
//            button1.titleLabel?.text = "Stop"
//            updateText("Playing \(Int(oscillator.frequency))Hz")
//        }
    }
    @IBAction func slid1(_ sender: UISlider) {
        booster.gain = Double(slider1.value)
        //updateText("booster gain = \(booster.gain)")
    }

    @IBAction func slid2(_ sender: UISlider) {
        booster.rampTime = Double(slider2.value)
        //updateText("booster ramp time = \(booster.rampTime)")
    }

    func updateText(_ input: String) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.text = "\(input)\n\(self.outputTextView.text!)"
        })
    }

    @IBAction func clearText(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.outputTextView.text = ""
        })
    }
}
