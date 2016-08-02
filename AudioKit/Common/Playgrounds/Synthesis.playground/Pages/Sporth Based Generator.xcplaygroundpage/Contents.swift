//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sporth Based Generator
//: ### You can create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: ### With this playground you can load up a few demonstration sporth patches to try out.
import XCPlayground
import AudioKit

var generator = AKOperationGenerator(sporth: "")

//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Sporth Generators")
        
        addLabel("Choose one of the Sporth files:")

        let sporthFiles = ["Aurora",
                           "Chatting",
                           "Distant Intelligence",
                           "Influx",
                           "Plucked Strings",
                           "Simple Keyboard"]
        addSubview(AKPresetLoaderView(presets: sporthFiles) { filename in
            let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "sp")
            let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
            let sporth = NSString(data: contentData!, encoding: NSUTF8StringEncoding) as? String
            Swift.print("\n\n\n\n\n\n\(sporth!)")
            self.updateSporth(sporth!)
            })
        addSubview(AKPropertySlider(
            property: "Parameter 0",
            value: generator.parameters[0],
            color: AKColor.orangeColor()) { sliderValue in
                generator.parameters[0] = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Parameter 1",
            value: generator.parameters[1],
        color: AKColor.cyanColor()) { sliderValue in
            generator.parameters[1] = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Parameter 2",
            value: generator.parameters[2],
        color: AKColor.magentaColor()) { sliderValue in
            generator.parameters[2] = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Parameter 3",
        value: generator.parameters[3],
        color: AKColor.yellowColor()) { sliderValue in
            generator.parameters[3] = sliderValue
            })
        addLabel("Open up the console view to see the Sporth code.")

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)
    }
    
    
    func noteOn(note: MIDINoteNumber) {
        generator.parameters[4] = 1
        generator.parameters[5] = Double(note)
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        generator.parameters[4] = 0
    }

    func updateSporth(sporth: String) {
        generator.stop()
        AudioKit.stop()
        generator = AKOperationGenerator() { _ in return AKOperation(sporth) }
        AudioKit.output = generator
        AudioKit.start()
        generator.start()
    }

}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
