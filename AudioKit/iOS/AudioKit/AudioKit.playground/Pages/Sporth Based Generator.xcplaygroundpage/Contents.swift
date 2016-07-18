//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sporth Based Generator
//: ### You can also create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: ### This is an example of an effect written in Sporth.
import XCPlayground
import AudioKit

let chattingRobot =
    "'f1' '350 600 400' gen_vals " +
        "'f2' '600 1040 1620' gen_vals " +
        "'f3' '2400 2250 2400' gen_vals " +
        "'g1' '1 1 1' gen_vals " +
        "'g2' '0.28184 0.4468 0.251' gen_vals " +
        "'g3' '0.0891 0.354 0.354' gen_vals " +
        "'bw1' '40 60 40' gen_vals " +
        "'bw2' '80 70 80' gen_vals " +
        "'bw3' '100 110 100' gen_vals " +
        "0 2 0.1 1 sine 2 10 biscale " +
        "randi 11 pset 110 200 0.8 1 sine " +
        "2 8 biscale randi 3 20 30 jitter + " +
        "0.2 0.1 square dup 11 p 0 0 0 " +
        "'g1' tabread * 11 p 0 0 0 " +
        "'f1' tabread 11 p 0 0 0 " +
        "'bw1' tabread butbp swap dup 11 p 0 0 0 " +
        "'g2' tabread * 11 p 0 0 0 " +
        "'f2' tabread 11 p 0 0 0 " +
        "'bw2' tabread butbp swap 11 p 0 0 0 " +
        "'g3' tabread * 11 p 0 0 0 " +
        "'f3' tabread 11 p 0 0 0 " +
        "'bw3' tabread butbp + + " +
        "0.4 dmetro 0.5 maygate 0.01 port * 2.0 * dup jcrev +"

let drone = "4 metro 0.003 0.001 0.1 tenv 57 mtof 0.5 1 1 1 fm mul " +
            "3 metro 0.003 0.001 0.1 tenv 64 mtof 0.5 1 1 1 fm mul " +
            "2 metro 0.003 0.001 0.1 tenv 67 mtof 0.5 1 1 0.8 fm mul " +
            "\"notes\" \"73 75 76 78\" gen_vals " +
            "0.5 metro dup 0.003 0.001 0.1 tenv swap " +
            "\"notes\" tseq mtof 0.5 1 1 0.8 fm mul mix 0.3 mul"

var generator = AKOperationGenerator(operation: AKOperation(chattingRobot))

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {


    override func setup() {
        addTitle("Sporth Generators")

        addLabel("Choose from the examples below:")

        addButton("Chatting Robot", action: #selector(startChatting))
        addButton("Drone", action: #selector(startDrone))

    }

    //: Handle UI Events

    func startChatting() {
        updateSporth(chattingRobot)
    }

    func startDrone() {
        updateSporth(drone)
    }

    func updateSporth(sporth: String) {
        generator.stop()
        AudioKit.stop()
        generator = AKOperationGenerator(operation: AKOperation(sporth))
        AudioKit.output = generator
        AudioKit.start()
        generator.start()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
