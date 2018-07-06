//
//  ViewController.swift
//  SimpleAudioUnit
//
//  Created by Ryan Francesconi on 5/4/18.
//  Copyright © 2018 Ryan Francesconi. All rights reserved.
//

import AudioKit
import Cocoa

// A simple demo for showing how to load a single audio unit and route a player through it
class ViewController: NSViewController {
    // You can try different AUs by changing these values
    var requestedAU = "AUDelay"
    var requestedManufacturer = "Apple"

    var manager = AKAudioUnitManager()
    var player: AKPlayer?
    var mixer = AKMixer()

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = mixer

        if let audioFile = try? AKAudioFile(readFileName: "Organ.wav", baseDir: .resources) {
            let player = AKPlayer(audioFile: audioFile)
            player.isLooping = true
            player.buffering = .always
            self.player = player
        }

        do {
            try AudioKit.start()
        } catch let err as NSError {
            AKLog(err)
            return
        }

        AKLog("AudioKit is started")

        // Do any additional setup after loading the view.

        // For this example, we'll just use the manager to get a list of all installed Audio Units
        self.manager.requestEffects(completionHandler: { audioUnits in
            AKLog("Installed Audio Units:")
            for test in audioUnits {
                AKLog(test.name)
            }

            // We've decided ahead of time we're looking for the AUDelay unit...
            let item = audioUnits.first {
                $0.name == self.requestedAU &&
                    $0.manufacturerName == self.requestedManufacturer
            }
            guard let component = item else { return }
            self.createUnit(component.audioComponentDescription)
        })
    }

    // We ask the manager to instansiate the AU for us
    func createUnit(_ acd: AudioComponentDescription) {
        AKAudioUnitManager.createEffectAudioUnit(acd) { audioUnit in
            guard let audioUnit = audioUnit else {
                AKLog("* Unable to create audioUnit")
                return
            }
            DispatchQueue.main.async {
                self.connectUnit(audioUnit)
            }
        }
    }

    func connectUnit(_ avUnit: AVAudioUnit) {
        // make sure our player is good
        guard let player = player else { return }

        // take the format from the player for the chain
        let processingFormat = player.avAudioNode.outputFormat(forBus: 0)

        // connect the player to the delay
        AudioKit.connect(player.avAudioNode, to: avUnit, format: processingFormat)

        // connect the delay to the mixer
        AudioKit.connect(avUnit, to: mixer.avAudioNode, format: processingFormat)

        // ask the audio unit for a view controller, if it is an AU with no UI this will return nil
        // it's the job of the host to then create an interface. See the AudioUnitManager example.
        avUnit.auAudioUnit.requestViewController { viewController in
            guard let ui = viewController, let window = self.view.window else { return }

            DispatchQueue.main.async {
                // Create a floating window for the AU
                let unitWindow = NSWindow()
                unitWindow.title = (avUnit.auAudioUnit.manufacturerName ?? "") + ": " +
                    (avUnit.auAudioUnit.audioUnitName ?? "Untitled")
                // take over the window with this view controller
                unitWindow.contentViewController = ui

                // put the AU window next to our main one for example
                var origin = window.frame.origin
                origin.x += window.frame.width
                unitWindow.setFrameOrigin(origin)

                // link the AU window to the main
                self.view.window?.addChildWindow(unitWindow, ordered: NSWindow.OrderingMode.above)
            }
        }
    }

    @IBAction func handlePlayButton(_ sender: NSButton) {
        guard let player = player else { return }

        if sender.state == .on {
            player.play()
        } else {
            player.stop()
        }
    }

}
