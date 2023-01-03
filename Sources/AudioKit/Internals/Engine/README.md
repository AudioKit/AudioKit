
# AudioKit v6 Engine

After years of fighting with AVAudioEngine, we've decided to mostly eliminate it, relegating its use to just managing I/O.

(Rationale is here https://github.com/AudioKit/AudioKit/issues/2804)

## Approach 

- Instead of the recursive pull-based style of typical AUs, sort the graph and call the AUs in sequence with dummy input blocks (this makes for simpler stack traces and easier profiling).
- Write everything in Swift (AK needs to run in Playgrounds. Make use of @noAllocations and @nolocks)
- Host AUs (actually the same AUs as before!)
- Don't bother trying to reuse buffers and update in-place (this seems to be of marginal benefit on modern hardware)
- Preserve almost exactly the same API

## Parallel Audio Rendering

We decided to be ambitious and do parallel audio rendering using a work-stealing approach. So far we've gotten nearly a 4x speedup over the old AVAudioEngine based graph.

We create a few worker threads which are woken by the audio thread. Those threads process RenderJobs and push the indices of subsequent jobs into their work queues. Each RenderJob renders an AudioUnit.

## References

[Meet Audio Workgroups](https://developer.apple.com/videos/play/wwdc2020/10224/)

[Lock-Free Work Stealing](https://blog.molecular-matters.com/2015/08/24/job-system-2-0-lock-free-work-stealing-part-1-basics/)
