//
//  ViewController.swift
//  FilterEffects
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {

    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!

    let input = AKStereoInput()

    override func viewDidLoad() {
        super.viewDidLoad()

        delay = AKVariableDelay(input)
        delay.rampDuration = 0.5 // Allows for some cool effects
        delayMixer = AKDryWetMixer(input, delay)

        reverb = AKCostelloReverb(delayMixer)
        reverbMixer = AKDryWetMixer(delayMixer, reverb)

        booster = AKBooster(reverbMixer)

        AudioKit.output = booster
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        Audiobus.start()

        setupUI()
    }

    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10

        stackView.addArrangedSubview(AKSlider(
            property: "Delay Time",
            value: self.delay.time,
            format: "%0.2f s") { sliderValue in
                self.delay.time = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Delay Feedback",
            value: self.delay.feedback,
            range: 0 ... 0.99,
            format: "%0.2f") { sliderValue in
                self.delay.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Delay Mix",
            value: self.delayMixer.balance,
            format: "%0.2f") { sliderValue in
                self.delayMixer.balance = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Reverb Feedback",
            value: self.reverb.feedback,
            range: 0 ... 0.99,
            format: "%0.2f") { sliderValue in
                self.reverb.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Reverb Mix",
            value: self.reverbMixer.balance,
            format: "%0.2f") { sliderValue in
                self.reverbMixer.balance = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Output Volume",
            value: self.booster.gain,
            range: 0 ... 2,
            format: "%0.2f") { sliderValue in
                self.booster.gain = sliderValue
        })

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
