//: ## Audio Player
//:
import AudioKitPlaygrounds
import AudioKit

let mixloop = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .resources)

let player = try AKAudioPlayer(file: mixloop) {
    print("completion callback has been triggered!")
}

AudioKit.output = player
AudioKit.start()
player.looping = true

//: Don't forget to show the "debug area" to see what messages are printed by the player
//: and open the timeline view to use the controls this playground sets up....

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var inPositionSlider: AKPropertySlider?
    var outPositionSlider: AKPropertySlider?
    var playingPositionSlider: AKPropertySlider?
    var fadeInSlider: AKPropertySlider?
    var fadeOutSlider: AKPropertySlider?

    override func setup() {

        AKPlaygroundLoop(every: 1 / 60.0) {
            if player.duration > 0 {
                self.playingPositionSlider?.value = player.playhead
            }

        }
        addTitle("Audio Player")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: ["mixloop.wav", "drumloop.wav", "bassloop.wav", "guitarloop.wav", "leadloop.wav"]))

        addSubview(AKButton(title: "Disable Looping") { button in
            player.looping = !player.looping
            if player.looping {
                button.title = "Disable Looping"
            } else {
                button.title = "Enable Looping"
            }
        })

        addSubview(AKButton(title: "Direction: ➡️") {
            if player.isPlaying {
                player.stop()
            }
            player.reversed = !player.reversed
            if player.reversed {
                button.title = "Direction: ⬅️"
            } else {
                button.title = "Direction: ➡️"
            }
        })

        fadeInSlider = AKPropertySlider(
            property: "Fade In",
            format: "%0.2f s",
            value: player.fadeInTime, maximum: 2
        ) { sliderValue in
            player.fadeInTime = sliderValue
        }
        addSubview(fadeInSlider)

        fadeOutSlider = AKPropertySlider(
            property: "Fade Out",
            format: "%0.2f s",
            value: player.fadeOutTime, maximum: 2
        ) { sliderValue in
            player.fadeOutTime = sliderValue
        }
        addSubview(fadeOutSlider)

        inPositionSlider = AKPropertySlider(
            property: "In Position",
            format: "%0.2f s",
            value: player.startTime, maximum: 3.428
        ) { sliderValue in
            player.startTime = sliderValue
        }
        addSubview(inPositionSlider)

        outPositionSlider = AKPropertySlider(
            property: "Out Position",
            format: "%0.2f s",
            value: player.endTime, maximum: 3.428
        ) { sliderValue in
            player.endTime = sliderValue
        }
        addSubview(outPositionSlider)

        playingPositionSlider = AKPropertySlider(
            property: "Position",
            format: "%0.2f s",
            value: player.playhead, maximum: 3.428
        ) { _ in
            // Can't do player.playhead = sliderValue
        }
        addSubview(playingPositionSlider)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
