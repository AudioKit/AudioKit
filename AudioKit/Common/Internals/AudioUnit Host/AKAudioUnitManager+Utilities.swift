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
    public internal(set) static var internalAudioUnits = ["AKAmplitudeEnvelope",
                                                          "AKAutoWah",
                                                          "AKBandPassButterworthFilter",
                                                          "AKBandRejectButterworthFilter",
                                                          "AKBitCrusher",
                                                          "AKBooster",
                                                          "AKChorus",
                                                          "AKChowningReverb",
                                                          "AKClipper",
                                                          "AKCombFilterReverb",
                                                          "AKCostelloReverb",
                                                          "AKDCBlock",
                                                          "AKDecimator",
                                                          "AKDelay",
                                                          "AKDistortion",
                                                          "AKDynamicRangeCompressor",
                                                          "AKDynaRageCompressor",
                                                          "AKEqualizerFilter",
                                                          "AKFader",
                                                          "AKFlanger",
                                                          "AKFlatFrequencyResponseReverb",
                                                          "AKFormantFilter",
                                                          "AKHighPassButterworthFilter",
                                                          "AKHighPassFilter",
                                                          "AKHighShelfFilter",
                                                          "AKHighShelfParametricEqualizerFilter",
                                                          "AKKorgLowPassFilter",
                                                          "AKLowPassButterworthFilter",
                                                          "AKLowPassFilter",
                                                          "AKLowShelfFilter",
                                                          "AKLowShelfParametricEqualizerFilter",
                                                          "AKModalResonanceFilter",
                                                          "AKMoogLadder",
                                                          "AKPanner",
                                                          "AKPeakingParametricEqualizerFilter",
                                                          "AKPeakLimiter",
                                                          "AKPhaser",
                                                          "AKPitchShifter",
                                                          "AKResonantFilter",
                                                          "AKRhinoGuitarProcessor",
                                                          "AKRingModulator",
                                                          "AKRolandTB303Filter",
                                                          "AKStereoDelay",
                                                          "AKStringResonator",
                                                          "AKTanhDistortion",
                                                          "AKThreePoleLowpassFilter",
                                                          "AKTimePitch",
                                                          "AKToneComplementFilter",
                                                          "AKToneFilter",
                                                          "AKTremolo",
                                                          "AKVariableDelay",
                                                          "AKVariSpeed",
                                                          "AKZitaReverb"]

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

    /// request a list of MIDI Processors, will be returned async
    public static func midiProcessorComponents(completionHandler: AKComponentListCallback? = nil) {
        /// Locating components can be a little slow, especially the first time.
        /// Do this work on a separate dispatch thread.
        DispatchQueue.global(qos: .default).async {
            let predicate = NSPredicate(format: "typeName == '\(AVAudioUnitTypeMIDIProcessor)'", argumentArray: [])
            var availableMIDIProcessors = AVAudioUnitComponentManager.shared().components(matching: predicate)
            availableMIDIProcessors = availableMIDIProcessors.sorted { $0.name < $1.name }

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                completionHandler?(availableMIDIProcessors)
            }
        } // dispatch global
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public static func createEffectAudioUnit(_ componentDescription: AudioComponentDescription,
                                             completionHandler: @escaping AKEffectCallback) {
        AVAudioUnitEffect.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            completionHandler(avAudioUnit)
        }
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public static func createInstrumentAudioUnit(_ componentDescription: AudioComponentDescription,
                                                 completionHandler: @escaping AKInstrumentCallback) {
        AVAudioUnitMIDIInstrument.instantiate(with: componentDescription,
                                              options: .loadOutOfProcess) { avAudioUnit, _ in
            completionHandler(avAudioUnit as? AVAudioUnitMIDIInstrument)
        }
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public static func createMIDIProcessorAudioUnit(_ componentDescription: AudioComponentDescription,
                                                    completionHandler: @escaping AKMIDIProcessorCallback) {
        AVAudioUnit.instantiate(with: componentDescription,
                                options: .loadOutOfProcess) { avAudioUnit, _ in
            completionHandler(avAudioUnit)
        }
    }

    public static func canLoadInProcess(componentDescription: AudioComponentDescription) -> Bool {
        let flags = AudioComponentFlags(rawValue: componentDescription.componentFlags)
        return flags.contains(AudioComponentFlags.canLoadInProcess)
    }

    // Create an instance of an AudioKit internal effect based on a class name
    public static func createInternalEffect(name: String) -> AVAudioUnit? {
        var node: AKNode?
        // currently, the auAudioUnit.audioUnitName comes with "Local" on the front
        let name = name.replacingOccurrences(of: "Local AK", with: "AK")

        //  This would be nice, but it doesn't work in AudioKit currently due to the way AKNode is setup
//        if let anyClass = NSClassFromString("AudioKit." + name) {
//            if let aknode = anyClass as? AKNode.Type {
//                node = aknode.init()
//            }
//        }

        // kind of a maintainence mess, but there it is
        switch name {
        case "AKLowShelfFilter":
            node = AKLowShelfFilter()
        case "AKLowPassFilter":
            node = AKLowPassFilter()
        case "AKHighShelfFilter":
            node = AKHighShelfFilter()
        case "AKHighPassFilter":
            node = AKHighPassFilter()
        case "AKDecimator":
            node = AKDecimator()
        case "AKDistortion":
            node = AKDistortion()
        case "AKDelay":
            node = AKDelay()
        case "AKStereoDelay":
            node = AKStereoDelay()
        case "AKVariableDelay":
            node = AKVariableDelay()
        case "AKChorus":
            node = AKChorus()
        case "AKCompressor":
            node = AKCompressor()
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
        case "AKPanner":
            node = AKPanner()
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
        case "AKFader":
            node = AKFader()
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
        return node?.avAudioUnit
    }
}
