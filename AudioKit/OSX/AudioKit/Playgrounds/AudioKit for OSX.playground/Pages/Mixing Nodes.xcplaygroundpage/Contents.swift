//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: ### So, what about connecting two nodes to output instead of having all operations sequential? To do that, you'll need a mixer.
import XCPlayground
import AudioKit

//: This section prepares the players
let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file1 = bundle.pathForResource("808loop", ofType: "wav")
let file2 = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player1 = AKAudioPlayer(file1!)
player1.looping = true
let player1Window = AKAudioPlayerWindow(player1, title: "808 Loop")

let player2 = AKAudioPlayer(file2!)
player2.looping = true
let player2Window = AKAudioPlayerWindow(player2, title: "Full Band", xOffset: 640)

//: Any number of inputs can be equally summed into one output
let mixer = AKMixer(player1, player2)

audiokit.audioOutput = mixer
audiokit.start()

let containerView = NSView(frame: CGRectMake(0, 0, 300, 800))
XCPlaygroundPage.currentPage.liveView = containerView
let plot1 = EZAudioPlot(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300))
let plot2 = EZAudioPlot(frame: CGRect(x: 0.0, y: 400.0, width: 300.0, height: 300))

containerView.addSubview(plot1)
containerView.addSubview(plot2)

player1.output?.installTapOnBus(0, bufferSize: 512, format: player1.output?.outputFormatForBus(0)) { (buffer, time) -> Void in
    print(time)
    print(NSDate())
    buffer.frameLength = 512
    plot1.updateBuffer(buffer.floatChannelData[0], withBufferSize: 512)
}
player2.output?.installTapOnBus(0, bufferSize: 512, format: player2.output?.outputFormatForBus(0)) { (buffer, time) -> Void in
    buffer.frameLength = 512
    plot2.updateBuffer(buffer.floatChannelData[0], withBufferSize: 512)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
