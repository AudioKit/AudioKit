//
//  AKAudioUnitManager+Utilities.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 5/10/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Utility methods for common tasks related to Audio Units
extension AKAudioUnitManager {

    /// Internal audio units not including the Apple ones, only the custom ones
    public internal(set) static var internalAudioUnits = ["AKVariableDelay",
                                                          "AKChorus",
                                                          "AKFlanger",
                                                          "AKBitCrusher",
                                                          "AKClipper",
                                                          "AKDynamicRangeCompressor",
                                                          "AKDynaRageCompressor",
                                                          "AKAmplitudeEnvelope",
                                                          "AKTremolo",
                                                          "AKAutoWah",
                                                          "AKBandPassButterworthFilter",
                                                          "AKBandRejectButterworthFilter",
                                                          "AKDCBlock",
                                                          "AKEqualizerFilter",
                                                          "AKFormantFilter",
                                                          "AKHighPassButterworthFilter",
                                                          "AKHighShelfParametricEqualizerFilter",
                                                          "AKKorgLowPassFilter",
                                                          "AKLowPassButterworthFilter",
                                                          "AKLowShelfParametricEqualizerFilter",
                                                          "AKModalResonanceFilter",
                                                          "AKMoogLadder",
                                                          "AKPeakingParametricEqualizerFilter",
                                                          "AKResonantFilter",
                                                          "AKRolandTB303Filter",
                                                          "AKStringResonator",
                                                          "AKThreePoleLowpassFilter",
                                                          "AKToneComplementFilter",
                                                          "AKToneFilter",
                                                          "AKRhinoGuitarProcessor",
                                                          "AKPhaser",
                                                          "AKPitchShifter",
                                                          "AKTimePitch",
                                                          "AKVariSpeed",
                                                          "AKChowningReverb",
                                                          "AKCombFilterReverb",
                                                          "AKCostelloReverb",
                                                          "AKFlatFrequencyResponseReverb",
                                                          "AKZitaReverb",
                                                          "AKBooster",
                                                          "AKTanhDistortion"]

    /// request a list of all installed Effect AudioUnits, will be returned async
    public static func effectComponents(completionHandler: AKComponentListCallback? = nil) {
        // Locating components can be a little slow, especially the first time.
        // Do this work on a separate dispatch thread.
        DispatchQueue.global(qos: .default).async {
            // Predicate will return all types of effects including
            // kAudioUnitType_Effect and kAudioUnitType_MusicEffect
            // which are the ones that we care about here
            let predicate = NSPredicate(format: "typeName CONTAINS 'Effect'", argumentArray: [])
            var availableEffects = AVAudioUnitComponentManager.shared().components(matching: predicate)

            availableEffects = availableEffects.sorted { $0.name < $1.name }

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                completionHandler?(availableEffects)
            }
        } // dispatch global
    }

    /// request a list of Instruments, will be returned async
    public static func instrumentComponents(completionHandler: AKComponentListCallback? = nil) {
        /// Locating components can be a little slow, especially the first time.
        /// Do this work on a separate dispatch thread.
        DispatchQueue.global(qos: .default).async {
            let predicate = NSPredicate(format: "typeName == '\(AVAudioUnitTypeMusicDevice)'", argumentArray: [])
            var availableInstruments = AVAudioUnitComponentManager.shared().components(matching: predicate)
            availableInstruments = availableInstruments.sorted { $0.name < $1.name }

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                completionHandler?(availableInstruments)
            }
        } // dispatch global
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public static func createEffectAudioUnit(_ componentDescription: AudioComponentDescription,
                                             completionHandler: @escaping AKEffectCallback) {

        AVAudioUnitEffect.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit)
        }
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public static func createInstrumentAudioUnit(_ componentDescription: AudioComponentDescription,
                                                 completionHandler: @escaping AKInstrumentCallback) {
        AVAudioUnitMIDIInstrument.instantiate(with: componentDescription,
                                              options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit as? AVAudioUnitMIDIInstrument)
        }
    }

    // Create an instance of an AudioKit internal effect based on a class name
    public static func createInternalEffect(name: String) -> AVAudioUnit? {
        var node: AKNode?
        // this would be nice but isn't possible at the moment:
        //        if let anyClass = NSClassFromString("AudioKit." + auname) {
        //            if let aknode = anyClass as? AKNode.Type {
        //                let instance = aknode.init()
        //            }
        //        }

        switch name {
        case "AKVariableDelay":
            node = AKVariableDelay()
        case "AKChorus":
            node = AKChorus()
        case "AKFlanger":
            node = AKFlanger()
        case "AKBitCrusher":
            node = AKBitCrusher()
        case "AKClipper":
            node = AKClipper()
        case "AKRingModulator":
            node = AKRingModulator()
        case "AKDynamicRangeCompressor":
            node = AKDynamicRangeCompressor()
        case "AKDynaRageCompressor":
            node = AKDynaRageCompressor()
        case "AKAmplitudeEnvelope":
            node = AKAmplitudeEnvelope()
        case "AKTremolo":
            node = AKTremolo()
        case "AKAutoWah":
            node = AKAutoWah()
        case "AKBandPassButterworthFilter":
            node = AKBandPassButterworthFilter()
        case "AKBandRejectButterworthFilter":
            node = AKBandRejectButterworthFilter()
        case "AKDCBlock":
            node = AKDCBlock()
        case "AKEqualizerFilter":
            node = AKEqualizerFilter()
        case "AKFormantFilter":
            node = AKFormantFilter()
        case "AKHighPassButterworthFilter":
            node = AKHighPassButterworthFilter()
        case "AKHighShelfParametricEqualizerFilter":
            node = AKHighShelfParametricEqualizerFilter()
        case "AKKorgLowPassFilter":
            node = AKKorgLowPassFilter()
        case "AKLowPassButterworthFilter":
            node = AKLowPassButterworthFilter()
        case "AKLowShelfParametricEqualizerFilter":
            node = AKLowShelfParametricEqualizerFilter()
        case "AKModalResonanceFilter":
            node = AKModalResonanceFilter()
        case "AKMoogLadder":
            node = AKMoogLadder()
        case "AKPeakingParametricEqualizerFilter":
            node = AKPeakingParametricEqualizerFilter()
        case "AKResonantFilter":
            node = AKResonantFilter()
        case "AKRolandTB303Filter":
            node = AKRolandTB303Filter()
        case "AKStringResonator":
            node = AKStringResonator()
        case "AKThreePoleLowpassFilter":
            node = AKThreePoleLowpassFilter()
        case "AKToneComplementFilter":
            node = AKToneComplementFilter()
        case "AKToneFilter":
            node = AKToneFilter()
        case "AKRhinoGuitarProcessor":
            node = AKRhinoGuitarProcessor()
        case "AKPhaser":
            node = AKPhaser()
        case "AKPitchShifter":
            node = AKPitchShifter()
        case "AKChowningReverb":
            node = AKChowningReverb()
        case "AKCombFilterReverb":
            node = AKCombFilterReverb()
        case "AKCostelloReverb":
            node = AKCostelloReverb()
        case "AKFlatFrequencyResponseReverb":
            node = AKFlatFrequencyResponseReverb()
        case "AKZitaReverb":
            node = AKZitaReverb()
        case "AKBooster":
            node = AKBooster()
        case "AKTanhDistortion":
            node = AKTanhDistortion()
        case "AKTimePitch":
            node = AKTimePitch()
        case "AKVariSpeed":
            node = AKVariSpeed()
        default:
            return nil
        }
        (node as? AKToggleable)?.start()
        return node?.avAudioNode as? AVAudioUnit
    }

}
