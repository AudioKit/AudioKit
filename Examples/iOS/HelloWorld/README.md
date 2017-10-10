# AudioKit HelloWorld Example

Every good programming framework needs a "Hello World" and this is AudioKit's version of Hello World!  Basically, it is just the simplest and shortest amount of code that create an instrument and allow the user to start and stop that instrument from a button on the screen.  The app simply plays a pair of oscillators at random frequencies, but there are plenty of more complicated examples to try out once you have this one working.


This starter example is included in AudioKit in the Examples directory with versions for iOS, macOS, and tvOS.  There is also an iOS version of this example in Objective-C.  When you open the project you will see that there are two primary files that drive this example.  The ViewController.swift file contains all of the AudioKit code as well and the Main.storyboard contains the button that activates methods in the ViewController.swift file to control the instrument.   There are many storyboard tutorials available online, so we'll just focus on the ViewController.swift's AudioKit code.

The first step is to make an instrument available to every method in this class, so we create two instances of an AKOscillator:

```
    var oscillator = AKOscillator()
    var oscillator2 = AKOscillator()
```

Then, in viewDidLoad, hook up the oscillator to the speakers and start the AudioKit engine.

```
    AudioKit.output = AKMixer(oscillator, oscillator2)
    AudioKit.start()
```

Finally, we just to need to connect the button from the Main.storyboard file to an action.  The only AudioKit code here is to set the frequency of the oscillator and play/stop it.  The other parts are just to update the UI to reflect the state of the instrument.

```
    @IBAction func toggleSound(sender: UIButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            sender.setTitle("Play Sine Wave", forState: .Normal)
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
            sender.setTitle("Stop Sine Wave at \(Int(oscillator.frequency))Hz", forState: .Normal)
        }
    }
```

And that's it!

