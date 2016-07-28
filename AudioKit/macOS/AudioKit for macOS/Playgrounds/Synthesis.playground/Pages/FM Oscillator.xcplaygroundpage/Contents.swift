//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {
    
    // UI Elements we'll need to be able to access
    var frequencySlider: AKPropertySlider?
    var carrierMultiplierSlider: AKPropertySlider?
    var modulatingMultiplierSlider: AKPropertySlider?
    var modulationIndexSlider: AKPropertySlider?
    var amplitudeSlider: AKPropertySlider?
    var rampTimeSlider: AKPropertySlider?
    
    
    
    override func setup() {
        addTitle("FM Oscillator")
        
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLineBreak()
        
        addButton("Stun Ray", action: #selector(presetStunRay))
        addButton("Wobble", action: #selector(presetWobble))
        addButton("Fog Horn", action: #selector(presetFogHorn))
        addButton("Buzzer", action: #selector(presetBuzzer))
        addButton("Spiral", action: #selector(presetSpiral))
        addLineBreak()
        addButton("Randomize", action: #selector(presetRandom))
        
        frequencySlider = AKPropertySlider(
            property: "Frequency",
            format: "%0.2f Hz",
            value: oscillator.baseFrequency, maximum: 800,
            color: AKColor.yellowColor(),
            frame: CGRect(x: 30, y: 480, width: self.bounds.width - 60, height: 60)
        ) { frequency in
            oscillator.baseFrequency = frequency
        }
        self.addSubview(frequencySlider!)
        
        carrierMultiplierSlider = AKPropertySlider(
            property: "Carrier Multiplier",
            format: "%0.3f",
            value: oscillator.carrierMultiplier, maximum: 20,
            color: AKColor.redColor(),
            frame: CGRect(x: 30, y: 390, width: self.bounds.width - 60, height: 60)
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        }
        self.addSubview(carrierMultiplierSlider!)
        
        modulatingMultiplierSlider = AKPropertySlider(
            property: "Modulating Multiplier",
            format: "%0.3f",
            value: oscillator.modulatingMultiplier, maximum: 20,
            color: AKColor.greenColor(),
            frame: CGRect(x: 30, y: 300, width: self.bounds.width - 60, height: 60)
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        }
        self.addSubview(modulatingMultiplierSlider!)
        
        modulationIndexSlider = AKPropertySlider(
            property: "Modulation Index",
            format: "%0.3f",
            value: oscillator.modulationIndex, maximum: 100,
            color: AKColor.cyanColor(),
            frame: CGRect(x: 30, y: 210, width: self.bounds.width - 60, height: 60)
        ) { index in
            oscillator.modulationIndex = index
        }
        self.addSubview(modulationIndexSlider!)
        
        
        amplitudeSlider = AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: oscillator.amplitude, maximum: 1,
            color: AKColor.purpleColor(),
            frame: CGRect(x: 30, y: 120, width: self.bounds.width - 60, height: 60)
        ) { amplitude in
            oscillator.amplitude = amplitude
        }
        self.addSubview(amplitudeSlider!)
        
        rampTimeSlider = AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: oscillator.rampTime, maximum: 10,
            color: AKColor.orangeColor(),
            frame: CGRect(x: 30, y: 30, width: self.bounds.width - 60, height: 60)
        ) { time in
            oscillator.rampTime = time
        }
        self.addSubview(rampTimeSlider!)
        
    }
    
    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }
    
    func presetStunRay() {
        oscillator.presetStunRay()
        oscillator.start()
        updateUI()
    }
    
    func presetFogHorn() {
        oscillator.presetFogHorn()
        oscillator.start()
        updateUI()
    }
    
    func presetBuzzer() {
        oscillator.presetBuzzer()
        oscillator.start()
        updateUI()
    }
    
    func presetSpiral() {
        oscillator.presetSpiral()
        oscillator.start()
        updateUI()
    }
    
    func presetWobble() {
        oscillator.presetWobble()
        oscillator.start()
        updateUI()
    }
    
    func presetRandom() {
        oscillator.baseFrequency = frequencySlider!.randomize()
        oscillator.carrierMultiplier = carrierMultiplierSlider!.randomize()
        oscillator.modulatingMultiplier = modulatingMultiplierSlider!.randomize()
        oscillator.modulationIndex = modulationIndexSlider!.randomize()
        oscillator.start()
        updateUI()
    }
    
    func updateUI() {
        frequencySlider?.value            = oscillator.baseFrequency
        carrierMultiplierSlider?.value    = oscillator.carrierMultiplier
        modulatingMultiplierSlider?.value = oscillator.modulatingMultiplier
        modulationIndexSlider?.value      = oscillator.modulationIndex
        amplitudeSlider?.value            = oscillator.amplitude
        rampTimeSlider?.value             = oscillator.rampTime
        
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 750))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
