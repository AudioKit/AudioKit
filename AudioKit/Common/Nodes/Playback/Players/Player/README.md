# AKPlayer

AKPlayer is meant to be a simple yet powerful audio player that just works. It supports
scheduling of sounds, looping, fading, time-stretching, pitch-shifting and reversing.
Players can be locked to a common clock as well as video by using hostTime in the various play functions.
By default the player will buffer audio if needed, otherwise stream from disk. Reversing the audio will cause the
file to buffer. For seamless looping use buffered playback.

# AKDynamicPlayer

The dynamic player adds pitch shifting and time stretching to AKPlayer. Due to the relatively high cost of rendering these 
effects, it has been moved to its own subclass.
