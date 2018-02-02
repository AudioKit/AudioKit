//
//  AKBoosterViewController.swift
//  AKBooster
//
//  Created by Aurelius Prochazka on 6/27/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AKBoosterViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSSize(width: 800, height: 500)

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        NSLog("booster creation from factory")
        audioUnit = try AKBoosterAudioUnit(componentDescription: componentDescription, options: [])

        return audioUnit!
    }

    @IBAction func change(_ sender: NSSlider) {
        guard let boosterUnit = audioUnit as? AKBoosterAudioUnit,
            let leftAmplitudeParameter = boosterUnit.parameterTree?.parameter(withAddress: 0),
            let rightAmplitudeParameter = boosterUnit.parameterTree?.parameter(withAddress: 1)
            else { return }

        leftAmplitudeParameter.value = sender.floatValue
        rightAmplitudeParameter.value = sender.floatValue

    }

    @IBOutlet weak var amplitudeSlider: NSSlider!
}
