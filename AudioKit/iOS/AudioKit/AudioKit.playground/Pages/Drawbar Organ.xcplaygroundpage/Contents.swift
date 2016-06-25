//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Drawbar Organ
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

let oscillator1 = AKOscillator()
let oscillator2 = AKOscillator()
let oscillator3 = AKOscillator()
let oscillator4 = AKOscillator()
let oscillator5 = AKOscillator()
let oscillator6 = AKOscillator()
let oscillator7 = AKOscillator()
let oscillator8 = AKOscillator()
let oscillator9 = AKOscillator()


var oscillArr: [AKOscillator] = [oscillator1, oscillator2, oscillator3, oscillator4, oscillator5, oscillator6, oscillator7,oscillator8, oscillator9]

for i in 0...8 {
    oscillArr[i].amplitude = 0.1
    oscillArr[i].rampTime = 0.1
}

let mixer = AKMixer(oscillator1, oscillator2, oscillator3, oscillator4, oscillator5, oscillator6, oscillator7, oscillator8, oscillator9)
AudioKit.output = mixer
AudioKit.start()

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {
    
    var amplitudeLabel1: Label?
    var amplitudeLabel2: Label?
    var amplitudeLabel3: Label?
    var amplitudeLabel4: Label?
    var amplitudeLabel5: Label?
    var amplitudeLabel6: Label?
    var amplitudeLabel7: Label?
    var amplitudeLabel8: Label?
    var amplitudeLabel9: Label?
    
    override func setup() {
        addTitle("Drawbar Organ")
        
        let keyboard = KeyboardView(width: 500, height: 100, delegate: self)
        keyboard.frame.origin.y = 60
        
        self.addSubview(keyboard)
        
        amplitudeLabel1 = addLabel("16")
        amplitudeLabel1!.frame = CGRectMake(10, 225, 40, 80)
        let ampSli1 = addSlider(#selector(setAmplitude1), value: 0.1)
        ampSli1.frame = CGRectMake(10, 170, 20, 80)
        amplitudeLabel2 = addLabel("5\n1/3")
        amplitudeLabel2!.frame = CGRectMake(65, 225, 40, 80)
        
        let ampSli2 = addSlider(#selector(setAmplitude2), value: 0.1)
        ampSli2.frame = CGRectMake(65, 170, 20, 80)
        amplitudeLabel3 = addLabel("8")
        amplitudeLabel3!.frame = CGRectMake(120, 225, 40, 80)
        let ampSli3 = addSlider(#selector(setAmplitude3), value: 0.1)
        ampSli3.frame = CGRectMake(120, 170, 20, 80)
        amplitudeLabel4 = addLabel("4")
        amplitudeLabel4!.frame = CGRectMake(175, 225, 40, 80)
        let ampSli4 = addSlider(#selector(setAmplitude4), value: 0.1)
        ampSli4.frame = CGRectMake(175, 170, 20, 80)
        amplitudeLabel5 = addLabel("2\n2/3")
        amplitudeLabel5!.frame = CGRectMake(230, 225, 40, 80)
        let ampSli5 = addSlider(#selector(setAmplitude5), value: 0.1)
        ampSli5.frame = CGRectMake(230, 170, 20, 80)
        amplitudeLabel6 = addLabel("2")
        amplitudeLabel6!.frame = CGRectMake(285, 225, 40, 80)
        let ampSli6 = addSlider(#selector(setAmplitude6), value: 0.1)
        ampSli6.frame = CGRectMake(285, 170, 20, 80)
        amplitudeLabel7 = addLabel("1\n3/5")
        amplitudeLabel7!.frame = CGRectMake(340, 225, 40, 80)
        
        let ampSli7 = addSlider(#selector(setAmplitude7), value: 0.1)
        ampSli7.frame = CGRectMake(340, 170, 20, 80)
        amplitudeLabel8 = addLabel("1\n1/3")
        amplitudeLabel8!.frame = CGRectMake(395, 225, 40, 80)
        let ampSli8 = addSlider(#selector(setAmplitude8), value: 0.1)
        ampSli8.frame = CGRectMake(395, 170, 20, 80)
        amplitudeLabel9 = addLabel("1")
        amplitudeLabel9!.frame = CGRectMake(450, 225, 40, 80)
        let ampSli9 = addSlider(#selector(setAmplitude9), value: 0.1)
        ampSli9.frame = CGRectMake(450, 170, 20, 80)
        let rampSli = addSlider(#selector(setRamp), value: 0.1)
        rampSli.frame.origin.y = 10
        let rampLab = addLabel("Portamento")
        rampLab.frame = CGRectMake(200, 30, 120, 20)
    }
    
    func noteOn(note: Int) {
        setFrequency(note)
        start()
    }
    
    func noteOff(note: Int) {
        stop()
    }
    
    func start() {
        
        for i in 0...8 {
            oscillArr[i].play()
        }
    }
    func stop() {
        for i in 0...8 {
            oscillArr[i].stop()
        }
    }
    
    func setRamp(slider: Slider) {
        for i in 0...8 {
            oscillArr[i].rampTime = Double(slider.value)
        }
    }
    
    func setFrequency(val: Int) {
        oscillator1.frequency = (val-12).midiNoteToFrequency()
        oscillator2.frequency = (val+7).midiNoteToFrequency()
        oscillator3.frequency = val.midiNoteToFrequency()
        oscillator4.frequency = (val+12).midiNoteToFrequency()
        oscillator5.frequency = (val+19).midiNoteToFrequency()
        oscillator6.frequency = (val+24).midiNoteToFrequency()
        oscillator7.frequency = (val+28).midiNoteToFrequency()
        oscillator8.frequency = (val+31).midiNoteToFrequency()
        oscillator9.frequency = (val+36).midiNoteToFrequency()
    }
    
    func setAmplitude1(slider: Slider) {
        oscillator1.amplitude = Double(slider.value)
    }
    func setAmplitude2(slider: Slider) {
        oscillator2.amplitude = Double(slider.value)
    }
    func setAmplitude3(slider: Slider) {
        oscillator3.amplitude = Double(slider.value)
    }
    func setAmplitude4(slider: Slider) {
        oscillator4.amplitude = Double(slider.value)
    }
    func setAmplitude5(slider: Slider) {
        oscillator5.amplitude = Double(slider.value)
    }
    func setAmplitude6(slider: Slider) {
        oscillator6.amplitude = Double(slider.value)
    }
    func setAmplitude7(slider: Slider) {
        oscillator7.amplitude = Double(slider.value)
    }
    func setAmplitude8(slider: Slider) {
        oscillator8.amplitude = Double(slider.value)
    }
    func setAmplitude9(slider: Slider) {
        oscillator9.amplitude = Double(slider.value)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 400))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
