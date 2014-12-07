//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

class ___FILEBASENAME___: AKInstrument {

    // Instrument Properties
    var pan  = AKInstrumentProperty(value: 0.0, minimum: 0.0, maximum: 1.0)

    // Auxilliary Outputs (if any)
    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        // Instrument Properties
        addProperty(pan)

        // Note Properties
        let note = ___FILEBASENAME___Note()
        addNoteProperty(note.frequency)
        addNoteProperty(note.amplitude)

        // Instrument Definition
        let oscillator = AKFMOscillator();
        oscillator.baseFrequency = note.frequency;
        oscillator.amplitude = note.amplitude;
        connect(oscillator);

        let panner = AKPanner(audioSource: oscillator, pan: pan)
        connect(panner)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:panner)
    }
}

class ___FILEBASENAME___Note: AKNote {

    // Note Properties
    var frequency = AKNoteProperty(minimum: 440, maximum: 880)
    var amplitude = AKNoteProperty(minimum: 0,   maximum: 1)

    override init() {
        super.init()
        addProperty(frequency)
        addProperty(amplitude)
    }
}
