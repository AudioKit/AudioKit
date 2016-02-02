//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Convolution
//: ### Open the timeline view to use the controls this playground sets up.
//:
import UIKit
import XCPlayground
import AudioKit

class ViewController: AKPlaygroundViewController {

    var player: AKAudioPlayer?
    var mixer: AKDryWetMixer?

    override func viewDidLoad() {
        super.viewDidLoad()

        //: Set up AudioKit's audio graph
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource("drumloop", ofType: "wav")
        player = AKAudioPlayer(file!)
        player!.looping = true

        let stairwell = bundle.URLForResource("Impulse Responses/stairwell", withExtension: "wav")!
        let dish = bundle.URLForResource("Impulse Responses/dish", withExtension: "wav")!

        var stairwellConvolution = AKConvolution.init(player!, impulseResponseFileURL: stairwell, partitionLength: 8192)
        var dishConvolution = AKConvolution.init(player!, impulseResponseFileURL: dish, partitionLength: 8192)

        mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 0)

        AudioKit.output = mixer
        AudioKit.start()
        stairwellConvolution.start()
        dishConvolution.start()


        //: Create the UI
        addTitle("AKConvolution")
        addSwitch("toggle:")
        addLabel("Balance: Stairwell to Dish")
        addSlider("setBalance:")
    }

    //: Handle UI Events

    func toggle(switch: UISwitch) {
        if player!.isPlaying {
            player!.stop()
        } else {
            player!.play()
        }
    }

    func setBalance(slider: UISlider) {
        mixer?.balance = Double(slider.value)
    }


}

ViewController()

XCPlaygroundPage.currentPage.liveView = ViewController()
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

