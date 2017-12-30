# Timeline Tap

The timeline tap is an excellent way to schedule events to happen at a specific time, with sample accuracy.

The timeline callback can be called pre-render or post-render, defaults to false (post-render).  Pre-render is better for triggering MIDI as the sample offset is taken into consideration. Post-render is necessary for input/output data buffer manipulation since the buffers' mData is null during pre-render.

The best way to learn about is to check out the "SamplerMetronome" example project.