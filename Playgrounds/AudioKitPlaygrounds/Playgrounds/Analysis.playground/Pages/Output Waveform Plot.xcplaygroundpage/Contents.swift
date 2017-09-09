//: ## Output Waveform Plot
//: If you open the Assitant editor and make sure it shows the
//: "Output Waveform Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the waveform in real time
import AudioKitPlaygrounds
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()
oscillator.start()

import AudioKitUI

class LiveView: AKLiveViewController {
/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKADSRView.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKButton.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKKeyboardView.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKLiveViewController.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKPlaygroundLoop.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKPlaygroundView.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKPresetLoaderView.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKPropertyControl.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKResourceAudioFileLoaderView.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKRotaryKnob.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKSlider.swift/Users/aure/Developer/AudioKit/AudioKit/macOS/AudioKit/User Interface/AKTableView.swift/Users/aure/Developer/AudioKit/Examples/iOS/AudioUnitManager/AudioUnitManager/DropDown/DropDown/helpers/DPDKeyboardListener.swift/Users/aure/Developer/AudioKit/Examples/iOS/AudioUnitManager/AudioUnitManager/DropDown/DropDown/helpers/DPDUIView+Extension.swift/Users/aure/Developer/AudioKit/Examples/iOS/AudioUnitManager/AudioUnitManager/DropDown/DropDown/src/DropDown.swift/Users/aure/Developer/AudioKit/Examples/iOS/AudioUnitManager/AudioUnitManager/DropDown/DropDown/src/DropDownCell.swift/Users/aure/Developer/AudioKit/Examples/iOS/MetronomeSamplerSync/MetronomeSamplerSync/AppDelegate.swift/Users/aure/Developer/AudioKit/Examples/iOS/MetronomeSamplerSync/MetronomeSamplerSync/ViewController.swift/Users/aure/Developer/AudioKit/Examples/iOS/SongProcessor/SongProcessor/SongProcessor.swift/Users/aure/Developer/AudioKit/Examples/iOS/SongProcessor/SongProcessor/View Controllers/iTunes Library Access/SongViewController.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Analysis.playground/Pages/Output Waveform Plot.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Bit Crush Effect.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Compressor.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Dynamics Processor.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/DynaRage Tube Compressor.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Expander.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Fatten Effect.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Peak Limiter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Pitch Shift Operation.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Rhino Guitar Processor.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Ring Modulator.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Stereo Delay Operation.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/String Resonator.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Tanh Distortion.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Tremolo.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Effects.playground/Pages/Variable Delay Operation.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Band Pass Butterworth Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Band Reject Butterworth Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/High Pass Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/High Shelf Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Korg Low Pass Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Low Pass Butterworth Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Low Pass Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Low Shelf Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Modal Resonance Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Moog Ladder Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Resonant Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Filters.playground/Pages/Three-Pole Low Pass Filter.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Playback.playground/Pages/Recording Nodes.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Microtonality.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Morphing Oscillator Bank.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Morphing Oscillator.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Oscillator Synth.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Phase Distortion Oscillator Bank.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Phase Distortion Oscillator.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/PWM Oscillator Bank.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/PWM Oscillator.xcplaygroundpage/Contents.swift/Users/aure/Developer/AudioKit/Playgrounds/AudioKitPlaygrounds/Playgrounds/Synthesis.playground/Pages/Vocal Tract.xcplaygroundpage/Contents.swift
    override func viewDidLoad() {
        addTitle("Output Waveform Plot")

        addView(AKSlider(property: "Frequency",
                         value: oscillator.baseFrequency,
                         range: 0 ... 800,
                         format: "%0.2f Hz"
        ) { frequency in
            oscillator.baseFrequency = frequency
        })

        addView(AKSlider(property: "Carrier Multiplier",
                         value: oscillator.carrierMultiplier,
                         range: 0 ... 3
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulating Multiplier",
                         value: oscillator.modulatingMultiplier,
                         range: 0 ... 3
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulation Index",
                         value: oscillator.modulationIndex,
                         range: 0 ... 3
        ) { index in
            oscillator.modulationIndex = index
        })

        addView(AKSlider(property: "Amplitude", value: oscillator.amplitude) { amplitude in
            oscillator.amplitude = amplitude
        })

        addView(AKOutputWaveformPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
