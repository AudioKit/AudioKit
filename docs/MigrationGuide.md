# AudioKit 5 Migration Guide

1. The AudioKit singleton no longer exists so instead of writing

```
AudioKit.output = something
AudioKit.start()
AudioKit.stop()
```
you'll need to create an instead of an AudioKit Engine:
```
let engine = AudioEngine()
engine.output = something
engine.start()
engine.stop()
```

