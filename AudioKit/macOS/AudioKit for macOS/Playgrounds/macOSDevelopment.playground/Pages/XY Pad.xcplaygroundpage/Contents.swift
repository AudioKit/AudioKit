//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## XY Pad
//:
import Cocoa
import PlaygroundSupport
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.4
let delay = AKDelay(oscillator)
delay.feedback = 0.3
delay.time = 0.1
let reverb = AKCostelloReverb(delay)
let mix = AKDryWetMixer(delay, reverb, balance: 0.5)
AudioKit.output = mix
AudioKit.start()

class TouchView: NSView {
    var (path, currentPath) = (NSBezierPath(), NSBezierPath())

    override func draw(_ dirtyRect: NSRect) {
        guard let contextPtr = NSGraphicsContext.current()?.graphicsPort else {return}
        let context = unsafeBitCast(contextPtr, to: CGContext.self)
        context.clear(dirtyRect)
        path.stroke()
        currentPath.lineWidth = 2.0
        currentPath.stroke()
    }

    override func mouseDown(with theEvent: NSEvent) {
        currentPath = NSBezierPath()
        currentPath.move(to: theEvent.locationInWindow)
        oscillator.start()
        updateOscillator(with: theEvent)
    }

    override func mouseDragged(with theEvent: NSEvent) {
        currentPath.line(to: theEvent.locationInWindow)
        needsDisplay = true
        updateOscillator(with: theEvent)
    }

    override func mouseUp(with theEvent: NSEvent) {
        path.append(currentPath)
        currentPath = NSBezierPath()
        needsDisplay = true
        oscillator.stop()
    }

    func updateOscillator(with theEvent: NSEvent) {
        let x = theEvent.locationInWindow.x / self.bounds.width
        let y = theEvent.locationInWindow.y / self.bounds.height
        oscillator.baseFrequency = Double(x * 1_000)
        oscillator.modulationIndex = Double(y * 20)
    }
}

let touchView: TouchView = {
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.white.cgColor
    return $0
}(TouchView(frame: NSRect(x: 0, y: 0, width: 500, height: 1_000)))

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = touchView

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
