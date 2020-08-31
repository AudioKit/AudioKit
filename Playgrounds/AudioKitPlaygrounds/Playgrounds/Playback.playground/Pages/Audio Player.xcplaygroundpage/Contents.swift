//: ## Audio Player
//:
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI
import PlaygroundSupport

var player: AKPlayer!

if let mixloop = try? AKAudioFile(readFileName: "mixloop.wav") {
    player = AKPlayer(audioFile: mixloop)
    player.completionHandler = { AKLog("completion callback has been triggered!") }
    player.isLooping = true
    engine.output = player
    try engine.start()
    player.play()
}
//: Don't forget to show the "debug area" to see what messages are printed by the player
//: and open the timeline view to use the controls this playground sets up....

class LiveView: AKLiveViewController {

    // UI Elements we'll need to be able to access
    var inPositionSlider: AKSlider!
    var outPositionSlider: AKSlider!
    var playingPositionSlider: AKSlider!
    var fadeInSlider: AKSlider!
    var fadeOutSlider: AKSlider!

    override func viewDidLoad() {
        AKPlaygroundLoop(every: 1 / 10.0) {
            if player.duration > 0 {
                self.playingPositionSlider?.value = player.currentTime
            }
        }
        addTitle("Audio Player")

        addView(AKButton(title: "Play") { button in
            player.play()
        })

        addView(AKButton(title: "Disable Looping") { button in
            player.isLooping = !player.isLooping
            button.title = player.isLooping ? "Disable Looping" : "Enable Looping"
        })

        addView(AKButton(title: "Normal →") { button in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.isReversed = !player.isReversed
            button.title = player.isReversed ? "Reversed ←" : "Normal →"
            if wasPlaying { player.play(from: 0) }
        })

        fadeInSlider = AKSlider(property: "Fade In",
                                value: player.fade.inTime,
                                range: 0 ... 2,
                                format: "%0.3f s"
        ) { sliderValue in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.fade.inTime = sliderValue

        }
        addView(fadeInSlider)

        fadeOutSlider = AKSlider(property: "Fade Out",
                                 value: player.fade.outTime,
                                 range: 0 ... 2,
                                 format: "%0.3f s"
        ) { sliderValue in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.fade.outTime = sliderValue
        }
        addView(fadeOutSlider)

        inPositionSlider = AKSlider(property: "In Position",
                                    value: 0,
                                    range: 0 ... 3.429,
                                    format: "%0.3f s"
        ) { sliderValue  in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.startTime = sliderValue
            player.loop.start = sliderValue
        }
        addView(inPositionSlider)

        outPositionSlider = AKSlider(property: "Out Position",
                                     value: 3.429,
                                     range: 0 ... 3.429,
                                     format: "%0.3f s"
        ) { sliderValue in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.endTime = sliderValue
            player.loop.end = sliderValue
        }
        addView(outPositionSlider)

        playingPositionSlider = AKSlider(property: "Position",
                                         value: player.currentTime,
                                         range: 0 ... player.duration,
                                         format: "%0.3f s"
        ) { _ in
            // Can't do player.currentTime = sliderValue
        }
        addView(playingPositionSlider)
    }
}
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
