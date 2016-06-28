//
//  AKMandolin.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Reads from the table sequentially and repeatedly at given frequency. Linear
/// interpolation is applied for table look up from internal phase values.
///
/// - parameter detuningOffset: Frequency offset in Hz.
/// - parameter detuningMultiplier: Frequency detuning multiplier
///
public class AKMandolin: AKNode {

    // MARK: - Properties

    internal var internalAU: AKMandolinAudioUnit?
    internal var token: AUParameterObserverToken?

    private var detuneParameter: AUParameter?
    private var bodySizeParameter: AUParameter?

    // Maybe eventually allow each string to have a rampable frequency
//    private var course1FrequencyParameter: AUParameter?
//    private var course2FrequencyParameter: AUParameter?
//    private var course3FrequencyParameter: AUParameter?
//    private var course4FrequencyParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }
    
    public var detune: Double = 1 {
        willSet {
            if detune != newValue {
                if internalAU!.isSetUp() {
                    detuneParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.detune = Float(newValue)
                }
            }
        }
    }

    public var bodySize: Double = 1 {
        willSet {
            if bodySize != newValue {
                if internalAU!.isSetUp() {
                    bodySizeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.bodySize = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization

    public init(
        detune: Double = 1,
        bodySize: Double = 1) {

        self.detune = detune
        self.bodySize = bodySize

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x706c756b /*'mand'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMandolinAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMandolin",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKMandolinAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        detuneParameter   = tree.valueForKey("detune")   as? AUParameter
        bodySizeParameter = tree.valueForKey("bodySize") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.detuneParameter!.address {
                    self.detune = Double(value)
                } else if address == self.bodySizeParameter!.address {
                    self.bodySize = Double(value)
                }
            }
        }
        internalAU?.detune = Float(detune)
        internalAU?.bodySize = Float(bodySize)
    }

    public func prepareChord(course1Note: Int,
                      _ course2Note: Int,
                      _ course3Note: Int,
                      _ course4Note: Int) {
        fret(note: course1Note, course: 0)
        fret(note: course2Note, course: 1)
        fret(note: course3Note, course: 2)
        fret(note: course4Note, course: 3)
    }
    
    public func fret(note note: Int, course: Int) {
        internalAU?.setFrequency(Float(note.midiNoteToFrequency()), course: Int32(course))
    }
    
    public func pluck(course course: Int, position: Double, velocity: Int) {
        internalAU?.pluckCourse(Int32(course), position: Float(position), velocity: Int32(velocity))
    }
    
    public func strum(position: Double, velocity: Int) {
        pluck(course: 0, position: position, velocity: velocity)
        pluck(course: 1, position: position, velocity: velocity)
        pluck(course: 2, position: position, velocity: velocity)
        pluck(course: 3, position: position, velocity: velocity)
    }

    public func mute(course course: Int) {
        
    }
    
    public func muteAllStrings() {
        mute(course: 0)
        mute(course: 1)
        mute(course: 2)
        mute(course: 3)
    }
}
