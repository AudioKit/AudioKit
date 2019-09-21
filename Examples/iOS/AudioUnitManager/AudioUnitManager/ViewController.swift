//
//  ViewController.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AudioKit
import AudioKitUI
import DropDown
import UIKit

/// This example demonstrates how to use two different input sources
/// (an AKAudioPlayer and an instrument Audio Unit) both sharing a
/// single signal chain.
class ViewController: UIViewController {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var auContainer: UIScrollView!
    @IBOutlet var instrumentButton: UIButton!
    @IBOutlet var keyboardContainer: UIView!

    var currentAU: AudioUnitGenericView?

    var effectMenus = [DropDown?](repeating: nil, count: 3)
    var instrumentMenu = DropDown()
    var effectButtons = [UIButton?](repeating: nil, count: 3)

    var auManager: AKAudioUnitManager?
    var mixer = AKMixer()
    var player: AKPlayer?
    var auInstrument: AKAudioUnitInstrument?

    var keyboard: AKKeyboardView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a manager instance
        auManager = AKAudioUnitManager()
        auManager?.delegate = self

        // async request a list of available effects units
        auManager?.requestEffects(completionHandler: { audioUnits in
            self.updateEffectsUI(audioUnits: audioUnits)
        })

        // and then an instruments list
        auManager?.requestInstruments(completionHandler: { audioUnits in
            self.updateInstrumentsUI(audioUnits: audioUnits)
        })

        // create some menus
        initDropDowns()

        if let audioFile = try? AKAudioFile(readFileName: "Organ.wav", baseDir: .resources) {
            let player = AKPlayer(audioFile: audioFile)
            player.isLooping = true
            player.buffering = .always //.dynamic
            player >>> mixer

            // setup the initial input/output connections
            auManager?.input = player
            auManager?.output = mixer

            self.player = player
        }

        // assign AudioKit's output to the mixer so it's easy to switch sources
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        // bounds for the container aren't ready yet here, so async it to the next update
        // to pick up the correct size
        DispatchQueue.main.async {
            let kframe = CGRect(x: 0,
                                y: 0,
                                width: self.keyboardContainer.bounds.size.width,
                                height: self.keyboardContainer.bounds.size.height)
            let keyboard = AKKeyboardView(frame: kframe)
            keyboard.delegate = self
            self.keyboardContainer.addSubview(keyboard)
            self.keyboard = keyboard
        }

    }

    // get a button by the tag set in the storyboard
    private func getEffectsButton(_ tag: Int) -> UIButton? {
        guard view != nil else { return nil }

        for sv in view.subviews {
            if let b = sv as? UIButton {
                if b.tag == tag {
                    return b
                }
            }
        }
        return nil
    }

    private func initDropDowns() {
        for i in 0 ..< 3 {

            if let button = getEffectsButton(i) {
                effectButtons[i] = button
            }

            effectMenus[i] = DropDown()
            effectMenus[i]?.anchorView = view
            effectMenus[i]?.direction = .any
            effectMenus[i]?.textFont = UIFont.systemFont(ofSize: 10)

            effectMenus[i]?.selectionAction = { [weak self] (_: Int, name: String) in
                guard let strongSelf = self else { return }
                guard let auManager = strongSelf.auManager else { return }

                if name == "-" {
                    auManager.removeEffect(at: i)
                    strongSelf.currentAU?.removeFromSuperview()
                } else {
                    auManager.insertAudioUnit(name: name, at: i)
                }

                strongSelf.effectButtons[i]?.setTitle(name, for: .normal)
                strongSelf.effectButtons[i]?.backgroundColor = UIColor.random()
            }
        }

        instrumentMenu.anchorView = view
        instrumentMenu.direction = .any
        instrumentMenu.textFont = UIFont.systemFont(ofSize: 10)
        instrumentMenu.selectionAction = { [weak self] (_: Int, name: String) in
            guard let strongSelf = self else { return }
            strongSelf.loadInstrument(name)
        }

    }

    /// tell the linked drop down to open
    @IBAction func handleChooseEffect(_ sender: UIButton) {
        guard sender.tag < 3 && sender.tag >= 0 else { return }
        effectMenus[sender.tag]?.show()
    }

    @IBAction func handleChooseInstrument(_ sender: UIButton) {
        instrumentMenu.show()
    }

    @IBAction func handlePlay(_ sender: UIButton) {
        guard let player = player else { return }

        // check to make sure the input is the player
        if auManager?.input != player {
            auManager?.connectEffects(firstNode: player, lastNode: mixer)
        }

        if player.isPlaying {
            AKLog("Stop")
            player.stop()
            sender.setTitle("▶️", for: .normal)

        } else {
            AKLog("Play")
            player.play()
            sender.setTitle("⏹", for: .normal)
        }
    }

    /// this is called to fill the drop downs with a list of available audio units
    fileprivate func updateEffectsUI(audioUnits: [AVAudioUnitComponent]) {
        for i in 0 ..< 3 {
            var effectMenuData = ["-"]

            for component in audioUnits where component.name != "" {
                effectMenuData.append(component.name)
            }

            effectMenus[i]?.dataSource = effectMenuData
        }
    }

    fileprivate func updateInstrumentsUI(audioUnits: [AVAudioUnitComponent]) {
        guard auManager != nil else { return }

        var effectMenuData = ["-"]

        for component in audioUnits where component.name != "" {
            effectMenuData.append(component.name)
        }

        instrumentMenu.dataSource = effectMenuData
    }

    public func showAudioUnit(_ audioUnit: AVAudioUnit) {

        if currentAU != nil {
            currentAU?.removeFromSuperview()
        }

        let au = AudioUnitGenericView(au: audioUnit)
        auContainer.addSubview(au)
        auContainer.contentSize = au.frame.size
        currentAU = au

    }

    public func loadInstrument(_ name: String) {
        guard let auManager = auManager else { return }

        instrumentButton.setTitle("🎹: \(name)", for: .normal)

        if name == "-" {
            // reassign back to player
            auManager.input = player
            auManager.output = mixer

        } else {
            showInstrument(name)
        }
    }

    public func showInstrument(_ auname: String) {
        guard let auManager = auManager else { return }

        auManager.createInstrument(name: auname, completionHandler: { audioUnit in
            guard let audioUnit = audioUnit else { return }

            AKLog("* \(audioUnit.name) : Audio Unit created")

            if self.auInstrument != nil {
                // dispose
            }

            self.auInstrument = AKAudioUnitInstrument(audioUnit: audioUnit)

            if self.auInstrument == nil {
                return
            }
            self.auManager?.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer)
            self.showAudioUnit(audioUnit)

        })
    }
}

extension ViewController: AKAudioUnitManagerDelegate {
    func handleAudioUnitManagerNotification(_ notification: AKAudioUnitManager.Notification,
                                            audioUnitManager: AKAudioUnitManager) {
        guard let auManager = auManager, audioUnitManager == auManager else { return }

        switch notification {
        case .changed:
            updateEffectsUI(audioUnits: auManager.availableEffects)
            updateInstrumentsUI(audioUnits: auManager.availableInstruments)
        default:
            break
        }
    }

    func audioUnitManager(_ audioUnitManager: AKAudioUnitManager, didAddEffectAtIndex index: Int) {
        guard let player = player else { return }
        guard let auManager = auManager else { return }

        if player.isPlaying {
            player.stop()
            player.play()
        }

        if let audioUnit = auManager.effectsChain[index] {
            showAudioUnit(audioUnit)
        }
    }

    func audioUnitManager(_ audioUnitManager: AKAudioUnitManager, didRemoveEffectAtIndex index: Int) {

    }
}

extension ViewController: AKKeyboardDelegate {
    /// Note off events
    func noteOff(note: MIDINoteNumber) {
        guard let auInstrument = auInstrument else { return }
        auInstrument.stop(noteNumber: note, channel: 0)
    }

    /// Note on events
    func noteOn(note: MIDINoteNumber) {
        guard let auInstrument = auInstrument else { return }

        // check to make sure the input is the auInstrument
        if auManager?.input != auInstrument {
            auManager?.connectEffects(firstNode: auInstrument, lastNode: mixer)
        }
        auInstrument.play(noteNumber: note, channel: 0)
    }
}

// Just some random nonsense

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }
}
