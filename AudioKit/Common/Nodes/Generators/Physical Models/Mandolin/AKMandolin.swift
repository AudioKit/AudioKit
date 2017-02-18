//
//  AKMandolin.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Physical model of a 4 course mandolin
///
open class AKMandolin: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKMandolinAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "mand")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var detuneParameter: AUParameter?
    fileprivate var bodySizeParameter: AUParameter?

    // Maybe eventually allow each string to have a rampable frequency
//    private var course1FrequencyParameter: AUParameter?
//    private var course2FrequencyParameter: AUParameter?
//    private var course3FrequencyParameter: AUParameter?
//    private var course4FrequencyParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Detuning of second string in the course (1=Unison (deault), 2=Octave)
    open var detune: Double = 1 {
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

    /// Relative size of the mandoline (Default: 1, ranges ~ 0.5 - 2)
    open var bodySize: Double = 1 {
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

    /// Initialize the 4 course (string-pair) Mandolin
    ///
    /// - Parameters:
    ///   - detune:   Detuning of second string in the course (1=Unison (deault), 2=Octave)
    ///   - bodySize: Relative size of the mandoline (Default: 1, ranges ~ 0.5 - 2)
    ///
    public init(
        detune: Double = 1,
        bodySize: Double = 1) {

        self.detune = detune
        self.bodySize = bodySize

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        detuneParameter = tree["detune"]
        bodySizeParameter = tree["bodySize"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.detuneParameter?.address {
                    self?.detune = Double(value)
                } else if address == self?.bodySizeParameter?.address {
                    self?.bodySize = Double(value)
                }
            }
        })
        internalAU?.detune = Float(detune)
        internalAU?.bodySize = Float(bodySize)
    }

    /// Virutally pressing fingers on all the strings of the mandolin
    ///
    /// - Parameters:
    ///   - course1Note: MIDI note number for course 1
    ///   - course2Note: MIDI note number for course 2
    ///   - course3Note: MIDI note number for course 3
    ///   - course4Note: MIDI note number for course 4
    open func prepareChord(_ course1Note: MIDINoteNumber,
                           _ course2Note: MIDINoteNumber,
                           _ course3Note: MIDINoteNumber,
                           _ course4Note: MIDINoteNumber) {
        fret(noteNumber: course1Note, course: 0)
        fret(noteNumber: course2Note, course: 1)
        fret(noteNumber: course3Note, course: 2)
        fret(noteNumber: course4Note, course: 3)
    }

    /// Pressing a finger on a course of the mandolin
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI note number of fretted note
    ///   - course:     Which set of strings to press
    ///
    open func fret(noteNumber: MIDINoteNumber, course: Int) {
        internalAU?.setFrequency(Float(noteNumber.midiNoteToFrequency()), course: Int32(course))
    }

    /// Pluck an individual course
    ///
    /// - Parameters:
    ///   - course:   Which set of string parirs to pluck
    ///   - position: Position lengthwise along the string to pluck (0 - 1)
    ///   - velocity: MIDI Velocity as an amplitude of the pluck (0 - 127)
    ///
    open func pluck(course: Int, position: Double, velocity: MIDIVelocity) {
        internalAU?.pluckCourse(Int32(course), position: Float(position), velocity: Int32(velocity))
    }

    /// Strum all strings of the mandolin
    ///
    /// - Parameters:
    ///   - position: Position lengthwise along the string to pluck (0 - 1)
    ///   - velocity: MIDI Velocity as an amplitude of the pluck (0 - 127)
    ///
    open func strum(_ position: Double, velocity: MIDIVelocity) {
        pluck(course: 0, position: position, velocity: velocity)
        pluck(course: 1, position: position, velocity: velocity)
        pluck(course: 2, position: position, velocity: velocity)
        pluck(course: 3, position: position, velocity: velocity)
    }

// Add Mute Functionality
//
//    public func mute(course course: Int) {
//    }
//
//    public func muteAllStrings() {
//        mute(course: 0)
//        mute(course: 1)
//        mute(course: 2)
//        mute(course: 3)
//    }
}
