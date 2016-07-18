//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## XY Pad
//:
import Cocoa
import XCPlayground
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

    override func drawRect(dirtyRect: NSRect) {
        guard let contextPtr = NSGraphicsContext.currentContext()?.graphicsPort else {return}
        let context = unsafeBitCast(contextPtr, CGContext.self)
        CGContextClearRect(context, dirtyRect)
        path.stroke()
        currentPath.lineWidth = 2.0
        currentPath.stroke()
    }

    override func mouseDown(theEvent: NSEvent) {
        currentPath = NSBezierPath()
        currentPath.moveToPoint(theEvent.locationInWindow)
        oscillator.start()
        updateOscillator(theEvent)
    }

    override func mouseDragged(theEvent: NSEvent) {
        currentPath.lineToPoint(theEvent.locationInWindow)
        needsDisplay = true
        updateOscillator(theEvent)
    }

    override func mouseUp(theEvent: NSEvent) {
        path.appendBezierPath(currentPath)
        currentPath = NSBezierPath()
        needsDisplay = true
        oscillator.stop()
    }

    func updateOscillator(theEvent: NSEvent) {
        let x = theEvent.locationInWindow.x/self.bounds.width
        let y = theEvent.locationInWindow.y/self.bounds.height
        oscillator.baseFrequency = Double(x * 1000)
        oscillator.modulationIndex = Double(y * 20)
    }
}

let touchView: TouchView = {
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.whiteColor().CGColor
    return $0
}(TouchView(frame: NSRect(x: 0, y: 0, width: 500, height: 1000)))

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = touchView

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
