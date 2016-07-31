//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Audio Player
//:
import XCPlayground
import AudioKit

//: Let's set a callback function that will be triggered when the player's playhead
//: reaches the end and stop. (This will only occur when player.looping is set to false)

func myCompletionCallBack() {
    print ("completion callBack has been triggered !")
}

//: Then, we create a player to play some guitar.
let guitarLoop = try? AKAudioFile(readFileName: "guitarloop.wav", baseDir: .Resources)

let player = try? AKAudioPlayer(file: guitarLoop!, completionHandler: myCompletionCallBack)

AudioKit.output = player
AudioKit.start()
player?.looping = true

//: Don't forget to show the "debug area" to see what messages are printed by the player
//: and open the timeline view to use the controls this playground sets up....

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var infoTextField: TextField?
    var durationTextField: TextField?
    var inPosSlider: Slider?
    var outPosSlider: Slider?
    var inPosTextField: TextField?
    var outPosTextField: TextField?
    var fileNameLabel: Label?
    var playingPosSlider: Slider?
    var playheadTextField: TextField?


    override func setup() {

        AKPlaygroundLoop(every: 1/60.0) {
            if player!.duration > 0 {
            self.playingPosSlider?.value = Float( player!.playhead / player!.duration)

            self.playheadTextField?.text =
                String(Int(100 * player!.playhead / player!.duration)) + " %"

            }

        }
        addTitle("Audio Player")

        fileNameLabel = addLabel("File name: \(player?.audioFile.fileNamePlusExtension)")

        addButton("Load Drum Loop", action: #selector(loadDrumLoop))
        addButton("Load Mix Loop", action: #selector(loadMixLoop))

        durationTextField = addTextField(nil, text: "Duration", value: player!.audioFile.duration)

        addLineBreak()

        addButton("Play", action: #selector(play))
        addButton("Stop", action: #selector(stop))
        addButton("Pause", action: #selector(pause))
        addLineBreak()

        addButton("Enable Looping", action: #selector(enableLooping))
        addButton("Disable Looping", action: #selector(disableLooping))
        addButton("Reload", action: #selector(reloadFile))

        addLineBreak()
        inPosTextField = addTextField(#selector(setInPosition),
                                      text: "In Position",
                                      value: player!.startTime)

        inPosSlider = addSlider(#selector(slideInPosition),
                                value: player!.startTime,
                                minimum: 0.0,
                                maximum: 4.0)

        outPosTextField = addTextField(#selector(setOutPosition),
                                       text: "Out Position",
                                       value: player!.endTime)

        outPosSlider = addSlider(#selector(slideOutPosition),
                                 value: player!.endTime,
                                 minimum: 0.0,
                                 maximum: 4.0)


        playheadTextField  = addTextField(nil, text: "PlayHead", value: 0)

        playingPosSlider = addSlider(#selector(playBackSlidePosTouched),
                                     value: player!.playhead,
                                     minimum: 0.0,
                                     maximum: 1.0)

        updateUI()
    }

    func play() {
        player!.play()
    }

    func stop() {
        player!.stop()
    }

    func pause() {
        player!.pause()
    }


    func enableLooping() {
        player!.looping = true
    }

    func disableLooping() {
        player!.looping = false
    }

    func loadDrumLoop() {
        let loopMp3 = try? AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

        try? player!.replaceFile(loopMp3!)
        updateUI()
    }

    func reloadFile() {
        try? player!.reloadFile()
        updateUI()
    }

    func loadMixLoop() {
        let mixloop = try? AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)
        try? player!.replaceFile(mixloop!)
        updateUI()
    }

    func updateSliders() {
        inPosSlider?.value = Float(player!.startTime)
        outPosSlider?.value = Float(player!.endTime)
    }

    func setInPosition(textField: TextField) {
        if let value = Double(textField.text!) {
            player!.startTime =  value
            updateSliders()
        }
    }
    func setOutPosition(textField: TextField) {
        if let value = Double(textField.text!) {
            player!.endTime =  value
            updateSliders()
        }
    }

    func updateTextFields() {
        let inPos = String(format: "%0.2f", player!.startTime) + " seconds"
        inPosTextField!.text = "\(inPos)"

        let outPos = String(format: "%0.2f", player!.endTime) + " seconds"
        outPosTextField!.text = "\(outPos)"
        let duration = String(format: "%0.2f", player!.audioFile.duration) + " seconds"
        durationTextField!.text = duration

        let fileName = player!.audioFile.fileNamePlusExtension
        fileNameLabel!.text = "File name: \(fileName)"
    }

    func slideInPosition(slider: Slider) {
        player!.startTime = Double(slider.value)
        updateTextFields()
    }

    func slideOutPosition(slider: Slider) {
        player!.endTime = Double(slider.value)
        updateTextFields()
    }

    func updateUI() {
        updateTextFields()
        updateSliders()
    }


    func playBackSlidePosTouched() {
        playingPosSlider?.value = Float( player!.playhead)
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
