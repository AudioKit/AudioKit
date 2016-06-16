//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKMagneto
//: # You can attach insert the AKMagneto at anymoint of the signal chain. For demo purpose, you listen here to the source mixed with the AKMagneto output. But you may use it as an insert. Here, AKMagneto is patched to the generator output before it passes thru the reverb. Record is appended to the file as long as you don't reset (tape is cleared).

import XCPlayground
import AudioKit

// Set a source for recording

let updateRate = AKOperation.parameters(0)

let start = AKOperation.randomNumberPulse() * 2000 + 300
let duration = AKOperation.randomNumberPulse()
let frequency = AKOperation.lineSegment(AKOperation.metronome(updateRate), start: start, end: 0, duration: duration)

let amplitude = AKOperation.exponentialSegment(AKOperation.metronome(updateRate), start: 0.3, end: 0.01, duration: 1.0 / updateRate)
let sine = AKOperation.sineWave(frequency: frequency, amplitude:  amplitude)

let generator = AKOperationGenerator(operation:  sine)

var delay = AKDelay(generator)
delay.time = 0.125
delay.feedback = 0.8
var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeHall)
reverb.dryWetMix = 1

// IF I TRY TO RECORD Generator, crash !
// But if I record the delay or the reverb output, it works fine...
// Any clue ?

let myMagneto = try? AKMagneto(node: delay)

let mixer = AKMixer(myMagneto!.output,reverb)

AudioKit.output = mixer
AudioKit.start()
generator.parameters = [2.0]

//: Here, we didn't provide an AKAudioFile to record to. So AKMagneto created one in the temp directory. You can get the recorded AKAudioFile like this
let recordedFile = myMagneto?.audioFile
let fileName = recordedFile?.fileNameWithExtension

//: You can then export/convert the recorded file into .wav or .M4a, using the AKAudioFile export method.


// Playground View
class PlaygroundView: AKPlaygroundView {

    var generatorLabel: Label?
    var magnetoLabel: Label?
    var replayPlayerLabel: Label?
    var speedLabel: Label?


    override func setup() {
        addTitle("AKMagneto")

        generatorLabel = addLabel("Generator:")
        addButton("startGenerator", action: #selector(startGenerator))
        addButton("stopGenerator", action: #selector(stopGenerator))
        speedLabel = addLabel("Update Rate: \(generator.parameters[0])")
        addSlider(#selector(setSpeed), value: generator.parameters[0], minimum: 0.1, maximum: 10)



        addLineBreak()
        magnetoLabel = addLabel("magneto:")

        addButton("Record", action: #selector(record))
        addButton("StopRecord", action: #selector(stopRecord))
        addButton("reset", action: #selector(magnetoReset))
        addLineBreak()
        addLabel("Auto-Input: ")
        addButton("On", action: #selector(setAutoInputToTrue))
        addButton("Off", action: #selector(setAutoInputToFalse))


        addLineBreak()
        replayPlayerLabel = addLabel("magneto: Replay")

        addButton("Replay", action: #selector(replay))
        addButton("StopReplay", action: #selector(stopReplay))
    }

    func setSpeed(slider: Slider) {
        generator.parameters[0] = Double(slider.value)
        speedLabel!.text = "Update Rate: \(String(format: "%0.3f", generator.parameters[0]))"
        delay.time = 0.25 / Double(slider.value)
    }

    // magneto record
    func  startGenerator()
    {
        generator.start()
    }
    func stopGenerator()
    {
        generator.stop()
    }


    // magneto record
    func  record()
    {
        myMagneto!.record()
    }
    func stopRecord()
    {
        myMagneto!.stopRecord()
    }

    func magnetoReset()
    {
        try? myMagneto!.reset()
    }

    func setAutoInputToFalse()
    {
        myMagneto!.autoInput = false
    }

    func setAutoInputToTrue()
    {
        myMagneto!.autoInput = true
    }


    // magneto playBack
    func replay()
    {
        myMagneto!.replay()
    }
    func stopReplay()
    {
        myMagneto!.stopReplay()
    }
    
}




let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
