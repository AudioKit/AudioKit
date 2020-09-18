//: ## Audio Player
//:

import AudioKit
import PlaygroundSupport

var player: AudioPlayer!

if let mixloop = try? AVAudioFile(readFileName: "mixloop.wav") {
    player = AudioPlayer(audioFile: mixloop)
    player.completionHandler = { Log("completion callback has been triggered!") }
    player.isLooping = true
    engine.output = player
    try engine.start()
    player.play()
}
//: Don't forget to show the "debug area" to see what messages are printed by the player
//: and open the timeline view to use the controls this playground sets up....

class LiveView: View {

    // UI Elements we'll need to be able to access
    var inPositionSlider: Slider!
    var outPositionSlider: Slider!
    var playingPositionSlider: Slider!
    var fadeInSlider: Slider!
    var fadeOutSlider: Slider!

    override func viewDidLoad() {
        PlaygroundLoop(every: 1 / 10.0) {
            if player.duration > 0 {
                self.playingPositionSlider?.value = player.currentTime
            }
        }
        addTitle("Audio Player")

        addView(Button(title: "Play") { button in
            player.play()
        })

        addView(Button(title: "Disable Looping") { button in
            player.isLooping = !player.isLooping
            button.title = player.isLooping ? "Disable Looping" : "Enable Looping"
        })

        addView(Button(title: "Normal →") { button in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.isReversed = !player.isReversed
            button.title = player.isReversed ? "Reversed ←" : "Normal →"
            if wasPlaying { player.play(from: 0) }
        })

        fadeInSlider = Slider(property: "Fade In",
                                value: player.fade.inTime,
                                range: 0 ... 2,
                                format: "%0.3f s"
        ) { sliderValue in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.fade.inTime = sliderValue

        }
        addView(fadeInSlider)

        fadeOutSlider = Slider(property: "Fade Out",
                                 value: player.fade.outTime,
                                 range: 0 ... 2,
                                 format: "%0.3f s"
        ) { sliderValue in
            let wasPlaying = player.isPlaying
            if wasPlaying { player.stop() }
            player.fade.outTime = sliderValue
        }
        addView(fadeOutSlider)

        inPositionSlider = Slider(property: "In Position",
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

        outPositionSlider = Slider(property: "Out Position",
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

        playingPositionSlider = Slider(property: "Position",
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
