//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Introduction and Hello World
//:
//: You don't need to understand anything on this page,
//: all you need to do is hear a one second long beep.
//: If you hear that, then everything worked and you can move on.
//: Sure, you can change the parameters on this page to hear different beeps,
//: but trust us, things are about to sound a lot cooler than just beeps!
//:
//: If your playground errors, build the frameworks by typing ⌘-B or
//: pressing the play button on Xcode, or choosing Product/Build from the menu.
import AudioKitPlaygrounds
import AudioKit

let oscillator = AKOscillator()

AudioKit.output = oscillator
AudioKit.start()

oscillator.start()

sleep(1)
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
