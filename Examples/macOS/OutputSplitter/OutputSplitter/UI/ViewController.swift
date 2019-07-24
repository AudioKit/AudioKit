//
//  ViewController.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Cocoa
import AudioKitUI

class ViewController: NSViewController {
    var playButton: AKButton!

    @IBOutlet weak var output1Selector: NSComboBox!
    @IBOutlet weak var output2Selector: NSComboBox!

    override func viewDidLoad() {
        super.viewDidLoad()

        playButton = AKButton()
        playButton.title = "Play"
        playButton.frame = NSRect(x: 0, y: view.bounds.height - 40, width: view.bounds.width, height: 40)
        view.addSubview(playButton)

        playButton.callback = { _ in
            if Application.engine.player.isPlaying {
                Application.engine.player.stop()
                self.playButton.title = "Play"
            } else {
                Application.engine.player.setPosition(0)
                Application.engine.player.play()
                self.playButton.title = "Stop"
            }
        }

        Application.start()
        setOutputDeviceSelectors()
    }

    func setOutputDeviceSelectors () {
        let outputDevices = EZAudioDevice.outputDevices() as! [EZAudioDevice]
        output1Selector.removeAllItems()
        output1Selector.addItems(withObjectValues: outputDevices.filter { $0.deviceID != Application.output2?.device.deviceID }.map { $0.name ?? "N/A" })
        output2Selector.removeAllItems()
        output2Selector.addItems(withObjectValues: outputDevices.filter { $0.deviceID != Application.output1?.device.deviceID }.map { $0.name ?? "N/A" })
        if Application.output1 != nil {
            output1Selector.stringValue = Application.output1!.device.name
        }

        if Application.output2 != nil {
            output2Selector.stringValue = Application.output2!.device.name
        }

    }

    @IBAction func output1Selected(_ sender: NSComboBox) {
        let device = Devices.output.first { $0.name == output1Selector.objectValueOfSelectedItem as? String }
        if (device != nil) {
            Application.selectOutputDevice1(device: device!)
            setOutputDeviceSelectors()
        }
    }

    @IBAction func output2Selected(_ sender: NSComboBox) {
        let device = Devices.output.first { $0.name == output2Selector.objectValueOfSelectedItem as? String }
        if (device != nil) {
            Application.selectOutputDevice2(device: device!)
            setOutputDeviceSelectors()
        }
    }
}
