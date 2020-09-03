//: ## Simple Reverb
//: This is an implementation of Apple's simplest reverb which only allows you to set presets
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var reverb = AKReverb(player)
reverb.dryWetMix = 0.5

engine.output = reverb
try engine.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Reverb")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Mix", value: reverb.dryWetMix) { sliderValue in
            reverb.dryWetMix = sliderValue
        })

        let presets = ["Cathedral", "Large Hall", "Large Hall 2",
                       "Large Room", "Large Room 2", "Medium Chamber",
                       "Medium Hall", "Medium Hall 2", "Medium Hall 3",
                       "Medium Room", "Plate", "Small Room"]
        addView(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Cathedral":
                reverb.loadFactoryPreset(.cathedral)
            case "Large Hall":
                reverb.loadFactoryPreset(.largeHall)
            case "Large Hall 2":
                reverb.loadFactoryPreset(.largeHall2)
            case "Large Room":
                reverb.loadFactoryPreset(.largeRoom)
            case "Large Room 2":
                reverb.loadFactoryPreset(.largeRoom2)
            case "Medium Chamber":
                reverb.loadFactoryPreset(.mediumChamber)
            case "Medium Hall":
                reverb.loadFactoryPreset(.mediumHall)
            case "Medium Hall 2":
                reverb.loadFactoryPreset(.mediumHall2)
            case "Medium Hall 3":
                reverb.loadFactoryPreset(.mediumHall3)
            case "Medium Room":
                reverb.loadFactoryPreset(.mediumRoom)
            case "Plate":
                reverb.loadFactoryPreset(.plate)
            case "Small Room":
                reverb.loadFactoryPreset(.smallRoom)
            default:
                break
            }
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
