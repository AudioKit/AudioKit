# AudioKit Tips and Tricks

## 1. Fix for 'Found an unexpected Mach-O header code: 0x72613c21' when submitting archive to app store

This happens when you drag the Audiokit project and source code into your xcode project instead of using a pre-built framework.
Go into the 'Build Settings' tab of your Audiokit and/or AudiokitUI projects, and search for 'mach'. Change Static Library to Dynamic Library.

## 2. Fix for AudiokitUI elements not rendering in Interface Builder

Similar to the Mach-O error, this happens when you drag the Audiokit project and source code into your xcode project instead of using a pre-built framework.
Go into the 'Build Settings' tab of your Audiokit and/or AudiokitUI projects, and search for 'mach'. Change Static Library to Dynamic Library.


## 3. Fix for 'unrecognized selector' bugs

Because AudioKit is a static framework, Xcode will strip out the parts of AudioKit that you don't need for your app, keeping the size small. But, sometimes it is bad at deciding what you need and you'll get bizarre 'unrecognized selector sent to instance' at runtime, even though things compile fine.  If this is happening to you.  Add the following to the  "Other Linker Flags" in the "Build Settings" tab for your app: "-all_load".  This will force all of AudioKit to load regardless of what Xcode deems you need. This should be a very rare occurrence, but its a great tip to keep in your arsenal.


## 4. Making AKAppleSampler not get corrupted by an audio route change 

When the audio session route changes (the iOS device is plugged into an external sound interface, headphones are connected, you start capturing a video on a mac using Quicktime...) AKSamplers start producing distorted audio.

Registering for audio route changes is simple and doesn't require anything from the basic app flow like the delegate or view controllers. Just do:

```
NotificationCenter.default.addObserver(self, selector: #selector(routeChanged), name: .AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
```

Define the event handler:

```
@objc func routeChanged(_ notification: Notification) {
	print("Audio route changed")
	
	AudioKit.stop() // Note 1

	do {
		try sampler.loadEXS24(yourSounds) // Note 2
	} catch  {
		print("could not load samples")
	}

	AudioKit.start()
}
```

Note 1: Sometimes stopping and starting AudioKit is not necessary. I suspect that this has something to do with sampling rates and bit rates, but I didn't investigate further, because I needed to support the stricter case anyway

Note 2: Samplers need to reload. AudioKit could implement route tracking in the main singleton, register all samplers and do this automatically to work properly out of the box.

## 5. Overridden math functions can show AKOperation related errors.  

This was originally documented [here](https://github.com/AudioKit/AudioKit/issues/1152).

```
func foo() {
	let a: Float = 10
	let b: Float = 20
	let c = abs(a+b)
	if c < 10.0 {
        // do something
	}
}
```

results in the error "Binary operator '<' cannot be applied to operands of type 'AKOperation' and 'Double'".

The solution is to explicitly declare `c` as a Float.  

```
func foo() {
	let a: Float = 10
	let b: Float = 20
	let c: Float = abs(a+b)
	if c < 10.0 {
        // do something
	}
}
```

The reason for this is that the `abs` function is redefined in AudioKit to allow you write audio operations but it is
incorrectly doing so here. This probably should be changed in AudioKit, but for now, its documented here as a common tip.
