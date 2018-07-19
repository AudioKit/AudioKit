//
//  ViewController.swift
//  SenderSynth
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController, AKKeyboardDelegate {

    let oscillator = AKOscillatorBank()
    var transportView: CAInterAppAudioTransportView?

    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = oscillator
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

        let adsrView = AKADSRView { att, dec, sus, rel in
            self.oscillator.attackDuration = att
            self.oscillator.decayDuration = dec
            self.oscillator.sustainLevel = sus
            self.oscillator.releaseDuration = rel
        }

        stackView.addArrangedSubview(adsrView)
        let keyboardView = AKKeyboardView()
        keyboardView.polyphonicMode = true
        keyboardView.delegate = self

        stackView.addArrangedSubview(keyboardView)

        let rect = CGRect(x: 0, y: 0, width: 300, height: 20)
        transportView = CAInterAppAudioTransportView(frame: rect)
        transportView?.setOutputAudioUnit(AudioKit.engine.outputNode.audioUnit!)

        stackView.addArrangedSubview(transportView!)

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

    func noteOn(note: MIDINoteNumber) {
        oscillator.play(noteNumber: note, velocity: 64)
    }

    func noteOff(note: MIDINoteNumber) {
        oscillator.stop(noteNumber: note)
    }

}
