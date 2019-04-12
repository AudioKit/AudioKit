# AKPlayer

AKPlayer is meant to be a simple yet powerful audio player that just works. It supports
scheduling of sounds, looping, fading, reversing, time-stretching and pitch-shifting.
Players can be locked to a common clock as well as video by using hostTime in the various play functions.
By default the player will buffer audio if needed, otherwise stream from disk. Reversing the audio will cause the
file to buffer. For seamless looping use buffered ram based playback.

# AKDynamicPlayer

The dynamic player adds pitch shifting and time stretching to AKPlayer. Due to the relatively high cost of rendering these 
effects, it has been moved to its own subclass. Regardless of that, both pitch and rate are disabled until you actually set
a valid value for them - only at this point is the internal AKTimePitch unit added.
