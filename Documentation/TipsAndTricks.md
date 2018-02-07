# AudioKit Tips and Tricks

1. Overridden math functions can show AKOperation related errors.  

This was originally documented [here](https://github.com/AudioKit/AudioKit/issues/1152).

```
func foo(){
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
func foo(){
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