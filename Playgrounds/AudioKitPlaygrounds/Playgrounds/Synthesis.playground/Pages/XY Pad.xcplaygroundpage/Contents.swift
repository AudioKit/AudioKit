//: ## XY Pad
//:

import AudioKit
import Cocoa

var oscillator = FMOscillator()
oscillator.amplitude = 0.4
let delay = Delay(oscillator)
delay.feedback = 0.3
delay.time = 0.1
let reverb = CostelloReverb(delay)
let mix = DryWetMixer(delay, reverb, balance: 0.5)
engine.output = mix
try engine.start()

class TouchView: NSView {
    var (path, currentPath) = (NSBezierPath(), NSBezierPath())

    override func draw(_ dirtyRect: NSRect) {
        guard let contextPtr = NSGraphicsContext.current?.graphicsPort else {
            return
        }
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

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = touchView
