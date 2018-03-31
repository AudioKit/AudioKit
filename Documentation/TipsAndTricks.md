# AudioKit Tips and Tricks

1. Because AudioKit is a static framework, Xcode will strip out the parts of AudioKit that you don't need for your app, keeping the size small. But, sometimes it is bad at deciding what you need and you'll get bizarre 'unrecognized selector sent to instance' at runtime, even though things compile fine.  If this is happening to you.  Add the following to the  "Other Linker Flags" in the "Build Settings" tab for your app: "-all_load".  This will force all of AudioKit to load regardless of what Xcode deems you need. This should be a very rare occurrence, but its a great tip to keep in your arsenal.

2. Overridden math functions can show AKOperation related errors.  

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