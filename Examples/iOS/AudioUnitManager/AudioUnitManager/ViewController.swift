//
//  ViewController.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 8/13/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
import DropDown

/// This example demonstrates how to use two different input sources
/// (an AKAudioPlayer and an instrument Audio Unit) both sharing a
/// single signal chain.
class ViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var auContainer: UIScrollView!
    @IBOutlet weak var instrumentButton: UIButton!
    @IBOutlet weak var keyboardContainer: UIView!

    var currentAU: AudioUnitGenericView?

    var effectMenus = [DropDown?](repeating: nil, count: 3)
    var instrumentMenu = DropDown()
    var effectButtons = [UIButton?](repeating: nil, count: 3)

    var auManager: AKAudioUnitManager?
    var mixer = AKMixer()
    var player: AKAudioPlayer?
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
            player = try? AKAudioPlayer(file: audioFile)
            if player != nil {
                player?.looping = true
                player! >>> mixer

                // setup the initial input/output connections
                auManager?.input = player
                auManager?.output = mixer
            }

        }

        // assign AudioKit's output to the mixer so it's easy to switch sources
        AudioKit.output = mixer
        AudioKit.start()

        // bounds for the container aren't ready yet here, so async it to the next update 
        // to pick up the correct size
        DispatchQueue.main.async {
            let kframe = CGRect(x:0,
                                y:0,
                                width:
                                self.keyboardContainer.bounds.size.width,
                                height: self.keyboardContainer.bounds.size.height)
            self.keyboard = AKKeyboardView(frame: kframe)
            self.keyboard!.delegate = self
            self.keyboardContainer.addSubview(self.keyboard!)
        }

    }

    // get a button by the tag set in the storyboard
    private func getEffectsButton(_ id: Int ) -> UIButton? {
        guard view != nil else { return nil }

        for sv in view.subviews {
            if  let b = sv as? UIButton {
                if b.tag == id {
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

            effectMenus[i]?.selectionAction = { [weak self] (index: Int, name: String) in
                print("handleSelectEffect() \(name)")

                guard let strongSelf = self else { return }
                guard strongSelf.auManager != nil else { return }

                if name == "-" {
                    strongSelf.auManager!.removeEffect(at: i)
                    if strongSelf.currentAU != nil {
                        strongSelf.currentAU?.removeFromSuperview()
                    }
                } else {
                    strongSelf.auManager!.insertAudioUnit(name: name, at: i)
                }

                strongSelf.effectButtons[i]?.setTitle(name, for: .normal)
                strongSelf.effectButtons[i]?.backgroundColor = UIColor.random()
            }
        }

        instrumentMenu.anchorView = view
        instrumentMenu.direction = .any
        instrumentMenu.textFont = UIFont.systemFont(ofSize: 10)
        instrumentMenu.selectionAction = { [weak self] (index: Int, name: String) in
            print("handleSelectInstrument() \(name)")
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
            auManager?.connectEffects(firstNode: player, lastNode: mixer )
        }

        if player.isStarted {
            player.stop()
            sender.setTitle("▶️", for: .normal)

        } else {
            player.play()
            sender.setTitle("⏹", for: .normal)
        }
    }

    /// this is called to fill the drop downs with a list of available audio units
    fileprivate func updateEffectsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard auManager != nil else { return }

        for i in 0 ..< 3 {
            var effectMenuData = ["-"]

            for component in audioUnits {
                if component.name != "" {
                    effectMenuData.append(component.name)
                }
            }

            effectMenus[i]?.dataSource = effectMenuData
        }
    }

    fileprivate func updateInstrumentsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard auManager != nil else { return }

        var effectMenuData = ["-"]

        for component in audioUnits {
            if component.name != "" {
                effectMenuData.append(component.name)
            }
        }

        instrumentMenu.dataSource = effectMenuData
    }

    public func showAudioUnit(_ audioUnit: AVAudioUnit) {

        if currentAU != nil {
            currentAU?.removeFromSuperview()
        }

        currentAU = AudioUnitGenericView(au: audioUnit)
        auContainer.addSubview(currentAU!)
        auContainer.contentSize = currentAU!.frame.size

    }

    public func loadInstrument(_ name: String) {
        guard auManager != nil else { return }

        instrumentButton.setTitle("🎹: \(name)", for: .normal)

        if name == "-" {
            // reassign back to player
            auManager!.input = player
            auManager!.output = mixer

        } else {
            showInstrument(name)
        }
    }

    public func showInstrument(_ auname: String ) {
        guard auManager != nil else { return }

        auManager!.createInstrument(name: auname, completionHandler: { audioUnit in
            guard let audioUnit = audioUnit else { return }

            AKLog("* \(audioUnit.name) : Audio Unit created")

            if self.auInstrument != nil {
                // dispose
            }

            self.auInstrument = AKAudioUnitInstrument(audioUnit: audioUnit)

            if self.auInstrument == nil {
                return
            }
            self.auManager?.connectEffects(firstNode: self.auInstrument, lastNode: self.mixer )
            self.showAudioUnit(audioUnit)

        })
    }
}

extension ViewController: AKAudioUnitManagerDelegate {
    func handleEffectRemoved(at auIndex: Int) {
        // Do nothing (for now?)
    }

    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
        guard auManager != nil else { return }

        if type == AKAudioUnitManager.Notification.changed {
            updateEffectsUI( audioUnits: auManager!.availableEffects )
            updateInstrumentsUI(audioUnits: auManager!.availableInstruments)
        }
    }

    /// this is where you can request the UI of the Audio Unit
    func handleEffectAdded(at auIndex: Int) {
        guard player != nil else { return }

        if player!.isStarted {
            player!.stop()
            player!.start()
        }

        if let au = auManager!.effectsChain[auIndex] {
            showAudioUnit(au)
        }
    }
}

extension ViewController: AKKeyboardDelegate {
    /// Note off events
    func noteOff(note: MIDINoteNumber) {
        guard auInstrument != nil else { return }
        auInstrument!.stop(noteNumber: note, channel: 0)
    }

    /// Note on events
    func noteOn(note: MIDINoteNumber) {
        guard auInstrument != nil else { return }

        // check to make sure the input is the auInstrument
        if auManager?.input != auInstrument {
            auManager?.connectEffects(firstNode: auInstrument, lastNode: mixer )
        }
        auInstrument!.play(noteNumber: note, channel: 0)
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
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
