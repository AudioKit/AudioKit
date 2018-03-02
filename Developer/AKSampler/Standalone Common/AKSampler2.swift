//
//  AKSampler2.swift
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-19.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

import AudioKit

/// Stereo Chorus
///
open class AKSampler2: AKPolyphonicNode, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKSampler2AudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "AKss")
    
    // MARK: - Properties
    
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?
    
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var ampAttackTimeParameter: AUParameter?
    fileprivate var ampDecayTimeParameter: AUParameter?
    fileprivate var ampSustainLevelParameter: AUParameter?
    fileprivate var ampReleaseTimeParameter: AUParameter?
    fileprivate var filterAttackTimeParameter: AUParameter?
    fileprivate var filterDecayTimeParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseTimeParameter: AUParameter?
    fileprivate var filterEnableParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }
    
    /// Pitch offset (semitones)
    @objc open dynamic var pitchBend: Double = 0.0 {
        willSet {
            if pitchBend == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && pitchBendParameter != nil {
                    pitchBendParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.pitchBend = newValue
        }
    }
    
    /// Vibrato amount (semitones)
    @objc open dynamic var vibratoDepth: Double = 1.0 {
        willSet {
            if vibratoDepth == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && vibratoDepthParameter != nil {
                    vibratoDepthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.vibratoDepth = newValue
        }
    }
    
    /// Amp attack time (seconds)
    @objc open dynamic var ampAttackTime: Double = 0.0 {
        willSet {
            if ampAttackTime != newValue {
                internalAU?.ampAttackTime = newValue
            }
        }
    }

    /// Amp Decay time (seconds)
    @objc open dynamic var ampDecayTime: Double = 0.0 {
        willSet {
            if ampDecayTime != newValue {
                internalAU?.ampDecayTime = newValue
            }
        }
    }
    
    /// Amp sustain level (fraction)
    @objc open dynamic var ampSustainLevel: Double = 1.0 {
        willSet {
            if ampSustainLevel != newValue {
                internalAU?.ampSustainLevel = newValue
            }
        }
    }
    
    /// Amp Release time (seconds)
    @objc open dynamic var ampReleaseTime: Double = 0.0 {
        willSet {
            if ampReleaseTime != newValue {
                internalAU?.ampReleaseTime = newValue
            }
        }
    }
    
    /// Filter attack time (seconds)
    @objc open dynamic var filterAttackTime: Double = 0.0 {
        willSet {
            if filterAttackTime != newValue {
                internalAU?.filterAttackTime = newValue
            }
        }
    }
    
    /// Filter Decay time (seconds)
    @objc open dynamic var filterDecayTime: Double = 0.0 {
        willSet {
            if filterDecayTime != newValue {
                internalAU?.filterDecayTime = newValue
            }
        }
    }
    
    /// Filter sustain level (fraction)
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            if filterSustainLevel != newValue {
                internalAU?.filterSustainLevel = newValue
            }
        }
    }
    
    /// Filter Release time (seconds)
    @objc open dynamic var filterReleaseTime: Double = 0.0 {
        willSet {
            if filterReleaseTime != newValue {
                internalAU?.filterReleaseTime = newValue
            }
        }
    }
    
    /// Filter Enable (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var filterEnable: Bool = false {
        willSet {
            if filterEnable != newValue {
                internalAU?.filterEnable = newValue ? 1.0 : 0.0
            }
        }
    }

    // MARK: - Initialization
    
    /// Initialize this sampler node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - startOffset: index of start sample (real-valued)
    ///   - playbackRate: ratio of playback rate to original sample rate (1.0 = normal)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        pitchBend: Double = 0.0,
        vibratoDepth: Double = 0.0,
        ampAttackTime: Double = 0.0,
        ampDecayTime: Double = 0.0,
        ampSustainLevel: Double = 1.0,
        ampReleaseTime: Double = 0.0,
        filterEnable: Bool = false,
        filterAttackTime: Double = 0.0,
        filterDecayTime: Double = 0.0,
        filterSustainLevel: Double = 1.0,
        filterReleaseTime: Double = 0.0) {
        
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.ampAttackTime = ampAttackTime
        self.ampDecayTime = ampDecayTime
        self.ampSustainLevel = ampSustainLevel
        self.ampReleaseTime = ampReleaseTime
        self.filterEnable = filterEnable
        self.filterAttackTime = filterAttackTime
        self.filterDecayTime = filterDecayTime
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseTime = filterReleaseTime
 
        _Self.register()
        
        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            
            input?.connect(to: self!)
        }
        
        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }
        
        self.pitchBendParameter = tree["pitchBend"]
        self.vibratoDepthParameter = tree["vibratoDepth"]
        self.ampAttackTimeParameter = tree["ampAttackTime"]
        self.ampDecayTimeParameter = tree["ampDecayTime"]
        self.ampSustainLevelParameter = tree["ampSustainLevel"]
        self.ampReleaseTimeParameter = tree["ampReleaseTime"]
        self.filterAttackTimeParameter = tree["filterAttackTime"]
        self.filterDecayTimeParameter = tree["filterDecayTime"]
        self.filterSustainLevelParameter = tree["filterSustainLevel"]
        self.filterReleaseTimeParameter = tree["filterReleaseTime"]
        self.filterEnableParameter = tree["filterEnable"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in
            
            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        self.internalAU?.setParameterImmediately(.pitchBendParam, value: pitchBend)
        self.internalAU?.setParameterImmediately(.vibratoDepthParam, value: vibratoDepth)
        self.internalAU?.setParameterImmediately(.ampAttackTimeParam, value: ampAttackTime)
        self.internalAU?.setParameterImmediately(.ampDecayTimeParam, value: ampDecayTime)
        self.internalAU?.setParameterImmediately(.ampSustainLevelParam, value: ampSustainLevel)
        self.internalAU?.setParameterImmediately(.ampReleaseTimeParam, value: ampReleaseTime)
        self.internalAU?.setParameterImmediately(.filterAttackTimeParam, value: filterAttackTime)
        self.internalAU?.setParameterImmediately(.filterDecayTimeParam, value: filterDecayTime)
        self.internalAU?.setParameterImmediately(.filterSustainLevelParam, value: filterSustainLevel)
        self.internalAU?.setParameterImmediately(.filterReleaseTimeParam, value: filterReleaseTime)
        self.internalAU?.setParameterImmediately(.filterEnableParam,
                                                 value: filterEnable ? 1.0 : 0.0)
    }
    
    open func loadAKAudioFile(noteNumber: MIDINoteNumber, noteHz: Float, file: AKAudioFile,
                              min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1,
                              bLoop: Bool = true, fLoopStart: Float = 0, fLoopEnd: Float = 0,
                              fStart: Float = 0, fEnd: Float = 0) {
        let sampleCount = UInt32(file.samplesCount)
        let channelCount = file.channelCount;
        let flattened = Array(file.floatChannelData!.joined())
        let data = UnsafeMutablePointer<Float>(mutating: flattened)
        internalAU?.loadSampleData(noteNumber, noteHz, false, channelCount, sampleCount, data,
                                   min_note, max_note, min_vel, max_vel,
                                   bLoop, fLoopStart, fLoopEnd, fStart, fEnd)
    }
    
    open func loadRawSampleData(noteNumber: MIDINoteNumber, noteHz: Float, data: UnsafeMutablePointer<Float>,
                                channelCount: UInt32, sampleCount: UInt32, bInterleaved: Bool = true,
                                min_note: Int32 = -1, max_note: Int32 = -1, min_vel: Int32 = -1, max_vel: Int32 = -1,
                                bLoop: Bool = true, fLoopStart: Float = 0, fLoopEnd: Float = 0,
                                fStart: Float = 0, fEnd: Float = 0) {
        internalAU?.loadSampleData(noteNumber, noteHz, bInterleaved, channelCount, sampleCount, data,
                                   min_note, max_note, min_vel, max_vel,
                                   bLoop, fLoopStart, fLoopEnd, fStart, fEnd)
    }
    
    open func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }
    
    open func buildKeyMap() {
        internalAU?.buildKeyMap()
    }
    
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.playNote(noteNumber, velocity, Float(frequency))
    }
    
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber, false)
    }
    
    open func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber, true)
    }
}

