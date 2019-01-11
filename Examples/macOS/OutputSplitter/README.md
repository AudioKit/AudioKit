## Very crude example of how to split Audio and pipe it to two different output devices.

Things that are very wrong:
* Audio will potentially crackle if devices have different Sample Rates and formats, need to introduce Converter Nodes.
* Hard coded artificial delay on starting the Output Engines, if delay is removed something (not sure what) is causing output callback to not be called.

People to thank:
* [Vlad Gorlov](https://github.com/vgorloff) for his [RingBuffer](https://github.com/vgorloff/CARingBuffer) class.
* [Jasmin Lapalme](https://github.com/jasminlapalme) for this [CAPlaythrough](https://github.com/jasminlapalme/caplaythrough-swift) rewrite to Swift
* Amateur code monkey [Roman Kisil](ttps://github.com/nodeful) for this poor example