# AudioKit HelloWorld Example

Every good programming framework needs a "Hello World" and this is AudioKit's version of Hello World!  Basically, it is just the simplest and shortest amount of code that create an instrument and allow the user to start and stop that instrument from a button on the screen.  The app simply plays a pair of oscillators at random frequencies, but there are plenty of more complicated examples to try out once you have this one working.


This starter example is included in AudioKit in the Examples directory with versions for iOS, macOS, and tvOS.  There is also an iOS version of this example in Objective-C.  When you open the project you will see that there are two primary files that drive this example.  The ViewController.swift file contains all of the AudioKit code as well and the Main.storyboard contains the button that activates methods in the ViewController.swift file to control the instrument.   There are many storyboard tutorials available online, so we'll just focus on the ViewController.swift's AudioKit code.

The first step is to make an instrument available to every method in this class, so we create two instances of an AKOscillator and a mixer to combine their sounds:

```
    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()   
```

Then, in viewDidLoad, hook up the oscillators to the speakers and start the AudioKit engine.

```
    mixer = AKMixer(oscillator1, oscillator2)

    // Cut the volume in half since we have two oscillators
    mixer.volume = 0.5
    AudioKit.output = mixer
    AudioKit.start()
```

Finally, we just to need to connect the button from the Main.storyboard file to an action.  The only AudioKit code here is to set the frequency of the oscillators and play/stop them.  The other parts are just to update the UI to reflect the state of the instrument.

```
    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = random(in: 220 ... 880)
            oscillator1.start()
            oscillator2.frequency = random(in: 220 ... 880)
            oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz & \(Int(oscillator2.frequency))Hz", for: .normal)
        }
    }
```

And that's it!

