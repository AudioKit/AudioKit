//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tone and Tone Complement Filters
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var toneFilter = AKToneFilter(player)
var toneComplement = AKToneComplementFilter(toneFilter)

AudioKit.output = toneComplement
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Tone Filters")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))

        addLabel("Tone Filter: ")
        
        addSubview(AKBypassButton(node: toneFilter))

        addSubview(AKPropertySlider(
            property: "Half Power Point",
            value: toneFilter.halfPowerPoint, maximum: 10000,
            color: AKColor.greenColor()
        ) { sliderValue in
            toneFilter.halfPowerPoint = sliderValue
            })

        addLabel("Tone Complement Filter: ")
        
        addSubview(AKBypassButton(node: toneComplement))

        addSubview(AKPropertySlider(
            property: "Half Power Point",
            value: toneComplement.halfPowerPoint, maximum: 10000,
            color: AKColor.greenColor()
        ) { sliderValue in
            toneComplement.halfPowerPoint = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
