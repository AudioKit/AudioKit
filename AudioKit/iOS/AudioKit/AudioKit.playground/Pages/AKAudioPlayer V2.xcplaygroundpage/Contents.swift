//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAudioPlayer
//:
import XCPlayground
import AudioKit

//: Let's set a callback function that will be triggered when the player's playhead reaches the end and stop. (This will only occur when player.looping is set to false)

func myCompletionCallBack()
{ print ("completion callBack has been triggered !")
}
//: Then, we create a player to play some guitar. 
let guitarLoop = try? AKAudioFile(forReadingFileName: "guitarloop", withExtension: "wav", fromBaseDirectory: .resources)

let player = try? AKAudioPlayer(AKAudioFile: guitarLoop!, completionHandler: myCompletionCallBack)

AudioKit.output = player
AudioKit.start()

//: Don't forget to show the "debug area" to see what messages are printed by the player and open the timeline view to use the controls this playground sets up....

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var infoTextField: TextField?
    var durationTextField: TextField?
    var inPosSlider: Slider?
    var outPosSlider: Slider?
    var inPosTextField: TextField?
    var outPosTextField: TextField?
    var fileNameLabel: Label?


    override func setup() {
        addTitle("AKAudioPlayer")

        fileNameLabel = addLabel("File name: \(player?.akAudioFile.fileNameWithExtension)")


        durationTextField = addTextField(nil, text: "Duration", value: player!.akAudioFile.duration)

        addLineBreak()

        addButton("Play", action: #selector(playSound))
        addButton("Stop", action: #selector(stopSound))
        addButton("Pause", action: #selector(pauseSound))
        addButton("Print playHead Pos", action: #selector(printPos))
        addLineBreak()

        addButton("loop On", action: #selector(setLoopOn))
        addButton("loop Off", action: #selector(setLoopOff))
        addButton("reLoad", action: #selector(reloadFile))

        addLineBreak()
        inPosTextField = addTextField(#selector(setInPos), text: "In Position", value: player!.startTime)

        inPosSlider = addSlider(#selector(slideInPos), value: player!.startTime, minimum: 0.0, maximum: 4.0)

        outPosTextField = addTextField(#selector(setOutPos), text: "Out Position", value: player!.endTime)

        outPosSlider = addSlider(#selector(slideOutPos), value: player!.endTime, minimum: 0.0, maximum: 4.0)
        addLineBreak()

        addButton("load drumLoop", action: #selector(loadDrumLoop))
        addButton("load mixLoop.wav", action: #selector(loadMixLoop))
        updateUI()

    }

    //: Handle UI Events

    func playSound() {
        print("button Play")
        player!.play()
    }
    func stopSound() {
    print("button Stop")
    player!.stop()
    }

    func pauseSound() {
        print("button Pause")

        player!.pause()
    }
    func printPos() {
        print ("playhead is at: \(player!.playhead) seconds")
    }
    //

    func setLoopOn() {
        print("button Loop On")
        player!.looping = true}
    func setLoopOff() {
        print("button Loop Off")
        player!.looping = false    }

    func loadDrumLoop() {
        print("button load DrumLoop")
        let loopMp3 = try? AKAudioFile(forReadingFileName: "drumloop", withExtension: "wav", fromBaseDirectory: .resources)

        player!.replaceAKAudioFile(loopMp3!)
        updateUI()

    }

    func reloadFile() {
        print("button reLoadFile")
        player!.reloadFile()
        updateUI()
    }

    func loadMixLoop() {
        print("button load MixLoop")
        let mixloop = try? AKAudioFile(forReadingFileName: "mixloop", withExtension: "wav", fromBaseDirectory: .resources)
        player!.replaceAKAudioFile(mixloop!)
        updateUI()
    }

    func updateSliders() {
        inPosSlider?.value = Float(player!.startTime)
        outPosSlider?.value = Float(player!.endTime)
    }

    func setInPos(textField: UITextField) {
        if let value = Double(textField.text!) {
            player!.startTime =  value
            updateSliders()
        }
    }
    func setOutPos(textField: UITextField) {
        if let value = Double(textField.text!) {
            player!.endTime =  value
            updateSliders()
        }
    }

    func updateTextFields() {
        let inPos = String(format: "%0.2f", player!.startTime)
        inPosTextField!.text = "\(inPos)"

        let outPos = String(format: "%0.2f", player!.endTime)
        outPosTextField!.text = "\(outPos)"
        let duration = String(format: "%0.2f", player!.akAudioFile.duration)
        durationTextField!.text = duration

        let fileName = player!.akAudioFile.fileNameWithExtension
        fileNameLabel!.text = "File name: \(fileName)"
    }

    func slideInPos(slider: Slider) {
        player!.startTime = Double(slider.value)
        updateTextFields()
    }
    func slideOutPos(slider: Slider) {
        player!.endTime = Double(slider.value)
        updateTextFields()
    }

    func updateUI() {
        updateTextFields()
        updateSliders()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
