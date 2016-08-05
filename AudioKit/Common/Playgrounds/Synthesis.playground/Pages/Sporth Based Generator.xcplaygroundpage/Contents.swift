//: ## Sporth Based Generator
//: ### You can create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: ### With this playground you can load up a few demonstration sporth patches to try out.
import XCPlayground
import AudioKit

var generator = AKOperationGenerator(sporth: "")

//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var p0Slider: AKPropertySlider?
    var p1Slider: AKPropertySlider?
    var p2Slider: AKPropertySlider?
    var p3Slider: AKPropertySlider?
    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("Sporth Generators")

        addLabel("Choose one of the Sporth files:")

        let sporthFiles = ["Aurora",
                           "Chatting",
                           "Crystalline",
                           "Distant Intelligence",
                           "Influx",
                           "kLtz",
                           "Simple Keyboard"]
        addSubview(AKPresetLoaderView(presets: sporthFiles) { filename in
            let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "sp")
            let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
            let sporth = NSString(data: contentData!, encoding: NSUTF8StringEncoding) as? String
            Swift.print("\n\n\n\n\n\n\(sporth!)")
            self.updateSporth(sporth!)

            let sliders = [self.p0Slider, self.p1Slider, self.p2Slider, self.p3Slider]

            // Reset UI Eleements
            self.keyboard?.hidden = true
            for i in 0 ..< 4 {
                sliders[i]?.hidden = true
                sliders[i]?.property = "Parameter \(i)"
                sliders[i]?.value = 0.0
            }

            // Process the comments in the file to customize the UI
            search: for  line in sporth!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            {
                if line.containsString("# Uses Keyboard") {
                    self.keyboard?.hidden = false
                    break search
                }

                for i in 0 ..< 4 {
                    let pattern = "# p\(i): ([.0-9]+)[ ]+([^\n]+)"
                    let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)

                    let value = regex.stringByReplacingMatchesInString(line, options: NSMatchingOptions.ReportCompletion, range: NSRange(location:0,
                        length: line.characters.count ), withTemplate: "$1")
                    let title = regex.stringByReplacingMatchesInString(line, options: NSMatchingOptions.ReportCompletion, range: NSRange(location:0,
                        length: line.characters.count ), withTemplate: "$2")
                    if title != line {
                        generator.parameters[i] = Double(value)!
                        sliders[i]?.hidden = false
                        sliders[i]?.property = title
                        sliders[i]?.value = Double(value)!
                    }
                }
            }

            })
        addLabel("Open up the console view to see the Sporth code.")

        p0Slider = AKPropertySlider(
            property: "Parameter 0",
            value: generator.parameters[0],
            color: AKColor.orangeColor()) { sliderValue in
                generator.parameters[0] = sliderValue
            }
        addSubview(p0Slider!)
        p1Slider = AKPropertySlider(
            property: "Parameter 1",
            value: generator.parameters[1],
        color: AKColor.cyanColor()) { sliderValue in
            generator.parameters[1] = sliderValue
            }
        addSubview(p1Slider!)
        p2Slider = AKPropertySlider(
            property: "Parameter 2",
            value: generator.parameters[2],
        color: AKColor.magentaColor()) { sliderValue in
            generator.parameters[2] = sliderValue
            }
        addSubview(p2Slider!)
        p3Slider = AKPropertySlider(
            property: "Parameter 3",
        value: generator.parameters[3],
        color: AKColor.yellowColor()) { sliderValue in
            generator.parameters[3] = sliderValue
            }
        addSubview(p3Slider!)

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        addSubview(keyboard!)
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
