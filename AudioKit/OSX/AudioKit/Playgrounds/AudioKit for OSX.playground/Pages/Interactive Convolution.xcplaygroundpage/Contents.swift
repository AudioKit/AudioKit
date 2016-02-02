//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Convolution
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

public class AKPlaygroundViewController: NSViewController {
    
    var positionIndex = 0
    public var elementHeight = CGFloat(30.0)
    public var horizontalSpacing = 40
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .whiteColor()
    }
    
    public func addTitle(text: String) -> NSTextField {
        let newLabel = NSTextField(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
//        newLabel.text = text
//        newLabel.center.x += 10
//        newLabel.center.y += CGFloat(horizontalSpacing * positionIndex)
//        newLabel.font =  UIFont.boldSystemFontOfSize(24)
//        view.addSubview(newLabel)
//        positionIndex += 1
        return newLabel
    }
    
    public func addSwitch(action: Selector) -> NSSegmentedControl {
        let newSwitch = NSSegmentedControl()
//        newSwitch.addTarget(self, action: "toggle:", forControlEvents: .TouchUpInside)
//        newSwitch.center.x += 10
//        newSwitch.center.y += CGFloat(horizontalSpacing * positionIndex)
//        view.addSubview(newSwitch)
//        positionIndex += 1
        return newSwitch
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> NSSlider {
        let newSlider = NSSlider(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
//        newSlider.center.x += 10
//        newSlider.center.y += CGFloat(horizontalSpacing * positionIndex)
        newSlider.minValue = minimum
        newSlider.maxValue = maximum
//        newSlider.value = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.target = self
        newSlider.action = action
//        newSlider.addTarget(self, action: action, forControlEvents: .ValueChanged)
        view.addSubview(newSlider)
        positionIndex += 1
        return newSlider
    }
    
    public func addLabel(text: String) -> NSTextField {
        let newLabel = NSTextField(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
//        newLabel.text = text
//        newLabel.center.x += 10
//        newLabel.center.y += CGFloat(horizontalSpacing * positionIndex)
//        view.addSubview(newLabel)
//        positionIndex += 1
        return newLabel
    }
    
}

class ViewController: AKPlaygroundViewController {
    
    //: Create an instance of AudioKit and an oscillator
    let audiokit = AKManager.sharedInstance
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
        
        audiokit.audioOutput = mixer
        audiokit.start()
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

