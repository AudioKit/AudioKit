//
//  AKNewSequencerTrackAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/31/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AVFoundation

public class AKNewSequencerTrackAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKNewSequencerTrackParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKNewSequencerTrackParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var startPoint: Double = AKNewSequencerTrack.defaultStartPoint {
        didSet { setParameter(.startPoint, value: startPoint) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createNewSequencerTrackDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let startPoint = AUParameter(
            identifier: "startPoint",
            name: "Start Point",
            address: AKNewSequencerTrackParameter.startPoint.rawValue,
            range: AKNewSequencerTrack.startPointRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [startPoint]))
        startPoint.value = Float(AKNewSequencerTrack.defaultStartPoint)
    }

    public override var canProcessInPlace: Bool { return true }

}
