//
//  AudioUnitViewController.swift
//  AKTanhDistortion
//
//  Created by Aurelius Prochazka on 6/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKTanhDistortionAudioUnit(componentDescription: componentDescription, options: [])

        return audioUnit!
    }

}
