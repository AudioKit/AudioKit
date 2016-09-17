//: ## Simple Reverb
//: This is an implementation of Apple's simplest reverb which only allows you to set presets

import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var reverb = AKReverb(player)
reverb.dryWetMix = 0.5

AudioKit.output = reverb
AudioKit.start()

player.play()


//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Reverb")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Mix",
            value: reverb.dryWetMix,
            color: AKColor.green
        ) { sliderValue in
            reverb.dryWetMix = sliderValue
            })

        let presets = ["Cathedral","Large Hall", "Large Hall 2",
                       "Large Room", "Large Room 2", "Medium Chamber",
                       "Medium Hall", "Medium Hall 2", "Medium Hall 3",
                       "Medium Room", "Plate", "Small Room"]
        addSubview(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Cathedral":
                reverb.loadFactoryPreset(.Cathedral)
            case "Large Hall":
                reverb.loadFactoryPreset(.LargeHall)
            case "Large Hall 2":
                reverb.loadFactoryPreset(.LargeHall2)
            case "Large Room":
                reverb.loadFactoryPreset(.LargeRoom)
            case "Large Room 2":
                reverb.loadFactoryPreset(.LargeRoom2)
            case "Medium Chamber":
                reverb.loadFactoryPreset(.MediumChamber)
            case "Medium Hall":
                reverb.loadFactoryPreset(.MediumHall)
            case "Medium Hall 2":
                reverb.loadFactoryPreset(.MediumHall2)
            case "Medium Hall 3":
                reverb.loadFactoryPreset(.MediumHall3)
            case "Medium Room":
                reverb.loadFactoryPreset(.MediumRoom)
            case "Plate":
                reverb.loadFactoryPreset(.Plate)
            case "Small Room":
                reverb.loadFactoryPreset(.SmallRoom)
            default: break
            }}
        )

    }

}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

PlaygroundPage.current.needsIndefiniteExecution = true
