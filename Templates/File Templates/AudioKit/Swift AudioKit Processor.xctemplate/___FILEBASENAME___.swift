//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

class ___FILEBASENAME___: AKInstrument {

    // Instrument Properties
    var feedback  = AKInstrumentProperty(value: 0.0, minimum: 0.0, maximum: 1.0)

    init(audioSource: AKAudio) {
        super.init()

        // Instrument Definition
        let reverb = AKReverb(
            audioSource: audioSource,
            feedbackLevel: feedback,
            cutoffFrequency: 4000.ak
        )
        setStereoAudioOutput(reverb)

        resetParameter(audioSource)
    }
}
