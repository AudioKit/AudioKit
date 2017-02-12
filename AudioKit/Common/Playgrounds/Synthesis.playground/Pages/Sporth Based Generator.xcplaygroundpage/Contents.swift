//: ## Sporth Based Generator
//: AudioKit nodes can be created using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: With this playground you can load up a few demonstration sporth patches to try out.

import AudioKit

var generator = AKOperationGenerator(sporth: "")
AudioKit.output = generator
AudioKit.start()
//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var p0Slider: AKPropertySlider?
    var p1Slider: AKPropertySlider?
    var p2Slider: AKPropertySlider?
    var p3Slider: AKPropertySlider?
    var keyboard: AKKeyboardView?
    var currentMIDINote: MIDINoteNumber = 0

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
            let filePath = Bundle.main.path(forResource: filename, ofType: "sp")
            //let filePath = Bundle.main.path(filename, ofType: "sp")
            let contentData = FileManager.default.contents(atPath: filePath!)
            //let contentData = FileManager.defaultManager().contentsAtPath(filePath!)

            let sporth = String(data: contentData!, encoding: .utf8)
            //let sporth = NSString(data: contentData!, encoding: String.Encoding.utf8) as? String

            Swift.print("\n\n\n\n\n\n\(sporth!)")
            generator.sporth = sporth!

            let sliders = [self.p0Slider, self.p1Slider, self.p2Slider, self.p3Slider]

            // Reset UI Eleements
            self.keyboard?.isHidden = true
            for i in 0 ..< 4 {
                sliders[i]?.isHidden = true
                sliders[i]?.property = "Parameter \(i)"
                sliders[i]?.value = 0.0
            }

            // Process the comments in the file to customize the UI
            search: for line in sporth!.components(separatedBy: NSCharacterSet.newlines)
            //search: for  line in sporth!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            {
                if line.contains("# Uses Keyboard") {
                    self.keyboard?.isHidden = false
                    break search
                }

                for i in 0 ..< 4 {
                    let pattern = "# p\(i): ([.0-9]+)[ ]+([^\n]+)"
                    let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

                    let value = regex.stringByReplacingMatches(in: line, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location:0,
                        length: line.characters.count ), withTemplate: "$1")
                    let title = regex.stringByReplacingMatches(in: line, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location:0,
                        length: line.characters.count ), withTemplate: "$2")
                    if title != line {
                        generator.parameters[i] = Double(value)!
                        sliders[i]?.isHidden = false
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
            color: AKColor.orange) { sliderValue in
                generator.parameters[0] = sliderValue
            }
        p0Slider?.isHidden = true
        addSubview(p0Slider!)
        p1Slider = AKPropertySlider(
            property: "Parameter 1",
            value: generator.parameters[1],
        color: AKColor.cyan) { sliderValue in
            generator.parameters[1] = sliderValue
            }
        p1Slider?.isHidden = true
        addSubview(p1Slider!)
        p2Slider = AKPropertySlider(
            property: "Parameter 2",
            value: generator.parameters[2],
        color: AKColor.magenta) { sliderValue in
            generator.parameters[2] = sliderValue
            }
        p2Slider?.isHidden = true
        addSubview(p2Slider!)
        p3Slider = AKPropertySlider(
            property: "Parameter 3",
        value: generator.parameters[3],
        color: AKColor.yellow) { sliderValue in
            generator.parameters[3] = sliderValue
            }
        p3Slider?.isHidden = true
        addSubview(p3Slider!)

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        keyboard!.isHidden = true
        addSubview(keyboard!)
    }

    func noteOn(note: MIDINoteNumber) {
        currentMIDINote = note
        generator.parameters[4] = 1
        generator.parameters[5] = Double(note)

    }

    func noteOff(note: MIDINoteNumber) {
        if currentMIDINote == note {
            generator.parameters[4] = 0
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
