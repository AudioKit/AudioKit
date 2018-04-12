//
//  ViewController.swift
//  AudiobusMIDISender
//
//  Created by Jeff Holtzkener on 2018/03/28.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DisplayDelegate {

    var abSequencer: AudiobusCompatibleSequencer!
    @IBOutlet var noteOnDisplay: [UIView]!
    @IBOutlet weak var isPlayingLabel: UILabel!
    let colors: [UIColor] = [UIColor(red: 43 / 255, green: 69 / 255, blue: 112 / 255, alpha: 1),
                             UIColor(red: 136 / 255, green: 73 / 255, blue: 143 / 255, alpha: 1),
                             UIColor(red: 148 / 255, green: 126 / 255, blue: 176 / 255, alpha: 1),
                             UIColor(red: 163 / 255, green: 165 / 255, blue: 195 / 255, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()
        setDisplayColors()
        showIsPlaying(false)
        abSequencer = AudiobusCompatibleSequencer()
        abSequencer.displayDelegate = self
    }

    // MARK: - Transport Control
    @IBAction func pressPlay(_ sender: Any) {
        abSequencer.play()
    }

    @IBAction func pressStop(_ sender: Any) {
        abSequencer.stop()
    }

    // MARK: - Display
    func showIsPlaying(_ isPlaying: Bool) {
        isPlayingLabel.text = isPlaying ? "Playing" : "Not Playing"
    }

    func flashNoteOnDisplay(index: Int, noteOn: Bool) {
        DispatchQueue.main.async { [weak self] in
            if noteOn {
                self?.noteOnDisplay[index].backgroundColor = self?.noteOnDisplay[index].backgroundColor?.withAlphaComponent(1)
            } else {
                UIView.animate(withDuration: 0.3) { self?.noteOnDisplay[index].backgroundColor = self?.noteOnDisplay[index].backgroundColor?.withAlphaComponent(0)
                }
            }
            self?.noteOnDisplay[index].backgroundColor = self?.noteOnDisplay[index].backgroundColor?.withAlphaComponent(noteOn ? 1 : 0)
        }
    }

    fileprivate func setDisplayColors() {
        for (i, _) in noteOnDisplay.enumerated() {
            noteOnDisplay[i].backgroundColor = colors[i].withAlphaComponent(0)
            noteOnDisplay[i].layer.masksToBounds = true
            noteOnDisplay[i].layer.cornerRadius = 10
        }
    }
}

protocol DisplayDelegate: class {
    func showIsPlaying(_ isPlaying: Bool)
    func flashNoteOnDisplay(index: Int, noteOn: Bool)
}
