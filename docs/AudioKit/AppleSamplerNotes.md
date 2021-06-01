# Apple Sampler Notes


## Making AppleSampler not get corrupted by an audio route change 

When the audio session route changes (the iOS device is plugged into an external sound interface, headphones are connected, you start capturing a video on a mac using Quicktime...) Samplers start producing distorted audio.

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
