# AudioKit Nodes

Nodes are interconnectable components that work with the audio stream. For a node to work, audio has to be pulled through it. For audio to be pulled through a node, the audio signal chain that includes the node has to eventually reach an output. 

AudioKit has several kinds of nodes:

## Analysis 

These nodes do not change the audio at all.  They examine the audio stream and extract information about the stream.  For example, the two most common uses for this are determining the audio's pitch and loudness.

## Effects

These nodes do change the audio stream.  They require an input to process.

## Generators

Generators create audio signal from scratch and as such they do not require an input signal.

## Input 

Like generator nodes, input nodes create audio, but in this case the audio that is create is retrieved from an input like a microphone or another app's output.

## Mixing

These nodes are about managing more than one sound simultaneously. Sounds can be combined, placed spatially, have their volumes changed, etc.

## Offline Rendering

This is for processing an audio quickly and saving it, rather than playing it in realtime through a speaker.

## Playback

Playback nodes are about playing and working with audio files.  We also include metronome nodes here.

