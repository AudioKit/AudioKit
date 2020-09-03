//: ## Sporth Based Generator
//: AudioKit nodes can be created using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: With this playground you can load up a few demonstration sporth patches to try out.
import AudioKitPlaygrounds
import AudioKit

var generator = AKOperationGenerator(sporth: "")
engine.output = generator
try engine.start()
//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var p0Slider: AKSlider!
    var p1Slider: AKSlider!
    var p2Slider: AKSlider!
    var p3Slider: AKSlider!
    var keyboard: AKKeyboardView!
    var currentMIDINote: MIDINoteNumber = 0

    override func viewDidLoad() {
        addTitle("Sporth Generators")

        addLabel("Choose one of the Sporth files:")

        let sporthFiles = ["Aurora",
                           "Chatting",
                           "Crystalline",
                           "Distant Intelligence",
                           "Influx",
                           "kLtz",
                           "Scheale",
                           "Simple Keyboard"]
        addView(AKPresetLoaderView(presets: sporthFiles) { filename in
            guard
                let filePath = Bundle.main.path(forResource: filename, ofType: "sp"),
                let contentData = FileManager.default.contents(atPath: filePath),
                let sporth = String(data: contentData, encoding: .utf8) else {
                    return
            }

            AKLog("\n\n\n\n\n\n\(sporth)")
            generator.sporth = sporth

            let sliders: [AKSlider] = [self.p0Slider, self.p1Slider, self.p2Slider, self.p3Slider]

            // Reset UI Eleements
//            self.keyboard.isHidden = true
            for i in 0 ..< 4 {
//                sliders[i].isHidden = true
                sliders[i].property = "Parameter \(i)"
                sliders[i].value = 0.0
            }

            var currentControl = 0
            search: for line in sporth.components(separatedBy: NSCharacterSet.newlines) {
                if line.contains("# Uses Keyboard") {
                    self.keyboard.isHidden = false
                    break search
                }

                var regex = NSRegularExpression()
                var pattern = "# default ([.0-9]+)"
                do {
                    regex = try NSRegularExpression(pattern: pattern,
                                                    options: .dotMatchesLineSeparators)
                } catch {
                    AKLog("Regular expression failed")
                }

                let value = regex.stringByReplacingMatches(in: line,
                                                           options: .reportCompletion,
                                                           range: NSRange(location: 0,
                                                                          length: line.count),
                                                           withTemplate: "$1")

                pattern = "##: - Control ([1-4]): ([^\n]+)"
                do {
                    regex = try NSRegularExpression(pattern: pattern,
                                                    options: .dotMatchesLineSeparators)
                } catch {
                    AKLog("Regular expression failed")
                }
                let currentControlText = regex.stringByReplacingMatches(in: line,
                                                                        options: .reportCompletion,
                                                                        range: NSRange(location: 0,
                                                                                       length: line.count),
                                                                        withTemplate: "$1")
                let title = regex.stringByReplacingMatches(in: line,
                                                           options: .reportCompletion,
                                                           range: NSRange(location: 0,
                                                                          length: line.count),
                                                           withTemplate: "$2")

                if title != line {
                    currentControl = (Int(currentControlText) ?? 0) - 1
                    sliders[currentControl].isHidden = false
                    sliders[currentControl].property = title
                }
                if value != line {
                    if let doubleValue = Double(value) {
                        generator.parameters[currentControl] = doubleValue
                        sliders[currentControl].value = doubleValue
                    }
                }
            }

        })
        addLabel("Open up the console view to see the Sporth code.")

        p0Slider = AKSlider(property: "Parameter 0", value: generator.parameters[0]) { sliderValue in
            generator.parameters[0] = sliderValue
        }
//        p0Slider?.isHidden = true
        addView(p0Slider)
        p1Slider = AKSlider(property: "Parameter 1", value: generator.parameters[1]) { sliderValue in
            generator.parameters[1] = sliderValue
        }
//        p1Slider?.isHidden = true
        addView(p1Slider)
        p2Slider = AKSlider(property: "Parameter 2", value: generator.parameters[2]) { sliderValue in
            generator.parameters[2] = sliderValue
        }
//        p2Slider?.isHidden = true
        addView(p2Slider)
        p3Slider = AKSlider(property: "Parameter 3", value: generator.parameters[3]) { sliderValue in
            generator.parameters[3] = sliderValue
        }
//        p3Slider?.isHidden = true
        addView(p3Slider)

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
//        keyboard.isHidden = true
        addView(keyboard)
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
PlaygroundPage.current.liveView = LiveView()
