//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Vocoder
import XCPlayground
import AudioKit

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let file = try AKAudioFile(readFileName: "counting.mp3", baseDir: .Resources)
var source = try AKAudioPlayer(file: file)
source.looping = true

let file2 = try AKAudioFile(readFileName: "80s Synth.mp3", baseDir: .Resources)
var excitation = try AKAudioPlayer(file: file2)
excitation.looping = true

let vocoder = AKVocoder(source, excitationSignal: excitation)

AudioKit.output = vocoder
AudioKit.start()
source.play()
excitation.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Vocoder")
        
        addLabel("Source")
        addSubview(AKResourcesAudioFileLoaderView(
            player: source,
            filenames: processingPlaygroundFiles))

        addLabel("Excitation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: excitation,
            filenames: processingPlaygroundFiles))
        
        addSubview(AKPropertySlider(
            property: "Attack Time",
            format:  "%0.3f s",
            value: vocoder.attackTime, minimum: 0.01, maximum: 0.5)
        { sliderValue in
                vocoder.attackTime = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Release Time",
            format:  "%0.3f s",
            value: vocoder.releaseTime, minimum: 0.01, maximum: 0.5)
        { sliderValue in
                vocoder.releaseTime = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Bandwidth Ratio",
            format:  "%0.3f",
            value: vocoder.bandwidthRatio, minimum: 0.1, maximum: 2)
        { sliderValue in
            vocoder.bandwidthRatio = sliderValue
        })

    }
    
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
