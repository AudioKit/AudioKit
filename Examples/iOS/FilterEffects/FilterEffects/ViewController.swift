//
//  ViewController.swift
//  FilterEffects
//
//  Created by Aurelius Prochazka on 10/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
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
        delay.rampTime = 0.5 // Allows for some cool effects
        delayMixer = AKDryWetMixer(input, delay)

        reverb = AKCostelloReverb(delayMixer)
        reverbMixer = AKDryWetMixer(delayMixer, reverb)

        booster = AKBooster(reverbMixer)

        AudioKit.output = booster
        AudioKit.start()
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

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Time",
            format: "%0.2f s",
            value: self.delay.time, minimum: 0, maximum: 1,
            color: UIColor.green) { sliderValue in
                self.delay.time = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Feedback",
            format: "%0.2f",
            value: self.delay.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.green) { sliderValue in
                self.delay.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Mix",
            format: "%0.2f",
            value: self.delayMixer.balance, minimum: 0, maximum: 1,
            color: UIColor.green) { sliderValue in
                self.delayMixer.balance = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Feedback",
            format: "%0.2f",
            value: self.reverb.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.red) { sliderValue in
                self.reverb.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Mix",
            format: "%0.2f",
            value: self.reverbMixer.balance, minimum: 0, maximum: 1,
            color: UIColor.red) { sliderValue in
                self.reverbMixer.balance = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Output Volume",
            format: "%0.2f",
            value: self.booster.gain, minimum: 0, maximum: 2,
            color: UIColor.yellow) { sliderValue in
                self.booster.gain = sliderValue
        })

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
