//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Audio Player
//:
import XCPlayground
import AudioKit

//: Let's set a callback function that will be triggered when the player's playhead reaches the end and stop. (This will only occur when player.looping is set to false)

func myCompletionCallBack(){
    print ("completion callBack has been triggered !")
}

//: Then, we create a player to play some guitar.
let guitarLoop = try? AKAudioFile(forReadingFileName: "guitarloop", withExtension: "wav", fromBaseDirectory: .resources)

let player = try? AKAudioPlayer(file: guitarLoop!, completionHandler: myCompletionCallBack)

AudioKit.output = player
AudioKit.start()
player?.looping = true

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
        addTitle("Audio Player")
        
        fileNameLabel = addLabel("File name: \(player?.audioFile.fileNameWithExtension)")
        
        addButton("Load Drum Loop", action: #selector(loadDrumLoop))
        addButton("Load Mix Loop", action: #selector(loadMixLoop))
        
        durationTextField = addTextField(nil, text: "Duration", value: player!.audioFile.duration)
        
        addLineBreak()
        
        addButton("Play", action: #selector(play))
        addButton("Stop", action: #selector(stop))
        addButton("Pause", action: #selector(pause))
        addButton("Print Playhead Position", action: #selector(printPosition))
        addLineBreak()
        
        addButton("Enable Looping", action: #selector(enableLooping))
        addButton("Disable Looping", action: #selector(disableLooping))
        addButton("Reload", action: #selector(reloadFile))
        
        addLineBreak()
        inPosTextField = addTextField(#selector(setInPosition), text: "In Position", value: player!.startTime)
        
        inPosSlider = addSlider(#selector(slideInPosition), value: player!.startTime, minimum: 0.0, maximum: 4.0)
        
        outPosTextField = addTextField(#selector(setOutPosition), text: "Out Position", value: player!.endTime)
        
        outPosSlider = addSlider(#selector(slideOutPosition), value: player!.endTime, minimum: 0.0, maximum: 4.0)
        
        updateUI()
    }
    
    //: Handle UI Events
    
    func play() {
        player!.play()
    }

    func stop() {
        player!.stop()
    }
    
    func pause() {
        player!.pause()
    }

    func printPosition() {
        print ("playhead is at: \(player!.playhead) seconds")
    }
    
    func enableLooping() {
        player!.looping = true
    }
    
    func disableLooping() {
        player!.looping = false
    }
    
    func loadDrumLoop() {
        let loopMp3 = try? AKAudioFile(forReadingFileName: "drumloop", withExtension: "wav", fromBaseDirectory: .resources)
        
        player!.replaceAKAudioFile(loopMp3!)
        updateUI()
    }
    
    func reloadFile() {
        player!.reloadFile()
        updateUI()
    }
    
    func loadMixLoop() {
        let mixloop = try? AKAudioFile(forReadingFileName: "mixloop", withExtension: "wav", fromBaseDirectory: .resources)
        player!.replaceAKAudioFile(mixloop!)
        updateUI()
    }
    
    func updateSliders() {
        inPosSlider?.value = Float(player!.startTime)
        outPosSlider?.value = Float(player!.endTime)
    }
    
    func setInPosition(textField: UITextField) {
        if let value = Double(textField.text!) {
            player!.startTime =  value
            updateSliders()
        }
    }
    func setOutPosition(textField: UITextField) {
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
        let duration = String(format: "%0.2f", player!.audioFile.duration)
        durationTextField!.text = duration
        
        let fileName = player!.audioFile.fileNameWithExtension
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
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
