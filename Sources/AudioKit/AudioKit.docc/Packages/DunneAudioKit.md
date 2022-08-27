# Dunne AudioKit

Chorus, Flanger, Sampler, Stereo Delay, and Synth for AudioKit, by Shane Dunne.

## Github URL

[https://github.com/AudioKit/DunneAudioKit/](https://github.com/AudioKit/DunneAudioKit/)

## Installation

Install with Swift Package Manager.

## API Reference

* [Chorus](https://audiokit.io/DunneAudioKit/documentation/dunneaudiokit/chorus)
* [Flanger](https://audiokit.io/DunneAudioKit/documentation/dunneaudiokit/flanger)
* [Sampler](https://audiokit.io/DunneAudioKit/documentation/dunneaudiokit/sampler)
* [Stereo Delay](https://audiokit.io/DunneAudioKit/documentation//dunneaudiokit/stereodelay)
* [Synth](https://audiokit.io/DunneAudioKit/documentation/dunneaudiokit/synth)
* [Transient Shaper](https://audiokit.io/DunneAudioKit/documentation/dunneaudiokit/transientshaper)
## Examples

See the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook/) for examples.

## Targets

| Name           | Description | Language      |
|----------------|-------------|---------------|
| DunneAudioKit  | API Layer   | Swift         |
| CDunneAudioKit | DSP Layer   | Objective-C++ |

## Modulation effects

As described by Will Pirkle in his excellent book "Designing Audio Effect Plug-Ins in C++", chorus and flanger are modulated-delay effects. A short delay line is used (up to 10 ms for flanger, or 24 ms for chorus), and the delay time is modulated using a low-frequency oscillator (LFO). Feedback is always used for flanging, typically not for chorus. There is also a wet/dry mix setting, which will normally be 50/50 for flanging. Setting the mix to 100% wet (for either effect) produces vibrato.

The code here is all original; none of Pirkle's code has been used.

These are both stereo effects (stereo-in, stereo-out). The modulator LFO signals used for the left and right channels are the same frequency, but differ in phase by 90 degrees.

These effects all take up to four parameters as follows:

### `frequency`
Frequency of the modulating LFO, Hz. Acceptable range 0.1 to 10.0 Hz. For chorus and flanger, you will usually use rates less than 2 Hz. For vibrato, 5 Hz sounds good.

### `depth`
Depth of modulation, expressed as a fraction 0.0 - 1.0. The higher the number, the more pronounced the effect.

### `feedback`
Another fractional scale factor which is the amount of delayed signal which is "fed back" into the input of the delay block. For flanger (which requires at least some feedback), the acceptable range is -0.95 - +0.95; negative values mean the feedback signal is inverted. For chorus (where feedback is usually not used), the acceptable range is 0.0 - 0.25. In both cases, numbers further from zero yield more pronounced effect.

### `dryWetMix`
The effects' output is a mix of the input ("dry") signal and the delayed ("wet") signal. The *dryWetMix* value is the scale factor (always a fraction 0.0 - 1.0) for the wet signal. The scale factor for the dry signal is computed internally as 1.0 - *dryWetMix*, so they always sum to unity. The higher the *dryWetMix* value, the more pronounced the effect.


## Modulated Delay Effects

Modulated-delay effects include **chorus**, **flanging**, and **vibrato**. These are all achieved by mixing an input signal with a delayed version of itself, and modulating the delay-time with a low-frequency oscillator (LFO).

![ModDelay Circuit Diagram](ModDelay.svg)

The LFO's output (typically a sinusoid or triangle wave) sets the instantaneous delay-time (i.e., the position of the output tap along the  delay-line's length), which then varies cyclically between limits *min _delay* and *max_delay*, about a midpoint *mid_delay*.

The balance between the "dry" (input) signal and the "wet" (delayed) signal is usually set based on a user-selected fraction *wf* applied as a scaling factor (*Wet Level* in the diagram) on the wet signal, with the corresponding *Dry Level* set as *1.0 − f*, so there is no net gain.

A user-selected *Rate* parameter sets the LFO frequency, and a *Depth* parameter sets the difference between *max_delay* and *min_delay*.

For some effects, a fraction (indicated as *Feedback* in the diagram) of the delayed signal is fed back into the delay line.

### Chorus
For a chorus effect, the delay time varies about *mid_delay* which is fixed at the midpoint of the delay-line, whose total length is typically 20-40 ms. A user-selected *Depth* parameter controls how far *mid_delay* and *max_delay* deviate from this central value, from a minimum of zero (no change) to the point where *min_delay* becomes zero. No feedback is used.

In the **Chorus** effect, *mid_delay* is fixed at 14 ms. Setting the *Depth* parameter to 1.0 (maximum) results in actual delay values of 14 ± 10 ms, i.e. *min_delay* = 4 ms, *max_delay* = 24 ms. The *Feedback* parameter will normally be left at the default value of 0, but can be set as high as 0.25. **Chorus** uses a sine-wave LFO, range 0.1 Hz to 10.0 Hz.

### Flanger
For a flanging effect, *min_delay* is fixed at nearly zero, and the user-selected *Depth* parameter controls *max_delay*, from a minimum of zero to a maximum of about 7-10 ms. Typical settings include a 50/50 wet/dry mix, and at least some feedback.

The *Feedback* parameter is a signed fraction in the range -1.0 to + 1.0, where negative values indicate that the signal is inverted before begin fed back. This is important because when the delay time gets very close to zero, the low-frequency parts of the wet and dry signals overlap almost perfectly, so positive feedback can result in a sudden increase in volume. Using negative feedback instead yields a momentary reduction in volume, which is less noticeable.

In the **Flanger** effect, setting the *Depth* parameter to 1.0 results in *max_delay* = 10 ms. *Feedback* may vary from -0.95 to +0.95. LFO is a triangle wave, 0.1 - 10 Hz.

### Vibrato
With a modulated-delay effect in either chorus (*mid_delay* fixed at midpoint of delay-line) or flanger (*min_delay* fixed at near-zero) configuration, setting the *Wet Level* to 100% will yield a vibrato effect. This is due to the effect of the LFO modulating the delay time. When the delay-time is decreasing, the short fragment of sound in the delay-line is effectively resampled at a rate faster than its original sample rate, so the pitch rises. When the delay-time is increasing, the sound is resampled at a rate slower than its original sampling rate, so the pitch drops.

### Stereo Chorus and Flanging
Both **Chorus** and **Flanger** are actually stereo effects. The DSP structure shown in the above diagram is duplicated for each of the Left and Right channels. The two LFOs run in lock-step at the same frequency (set by the *Rate* parameter) and amplitude (set by *Depth*), but offset in phase by 90 degrees. This technique, called *quadrature modulation*, is quite common in stereo modulation effects.

### For more information
Modulated-delay effects are described in detail in Chapter 10 of [Designing Audio Effect Plug-Ins in C++](https://www.amazon.com/Designing-Audio-Effect-Plug-Ins-Processing/dp/0240825152) by Will Pirkle.


## Sampler

**Sampler** is a new, polyphonic sample-playback engine built from scratch in C++.  It is 64-voice polyphonic and features a per-voice, stereo low-pass filter with resonance and ADSR envelopes for both amplitude and filter cutoff. Samples must be loaded into memory and remain resident there; it does not do streaming.  It reads standard audio files via **AVAudioFile**, as well as a more efficient [Wavpack](http://www.wavpack.com/)-based compressed format.

### Sampler vs AppleSampler

**AppleSampler** and its companion class **MIDISampler** are wrappers for Apple's *AUSampler* Audio Unit, an exceptionally powerful polyphonic, multi-timbral sampler instrument which is built-in to both macOS and iOS. Unfortunately, *AUSampler* is far from perfect and not properly documented. This **Sampler** is an attempt to provide an open-source alternative.

**Sampler** is nowhere near as powerful as *AUSampler*. If your app depends on **AppleSampler** or the **MIDISampler** wrapper class, you should continue to use it.

### Loading samples
**Sampler** provides three distinct mechanisms for loading samples:

1. `loadRawSampleData()` allows use of sample data already in memory, e.g. data generated programmatically or read using custom file-reading code.
2. `loadSFZ()` loads entire sets of samples by interpreting a simplistic subset of the "SFZ" soundfont file format.

`loadRawSampleData()` and `loadCompressedSampleFile()` take a "descriptor" argument (see next section below), whose many member variables define details like the sample's natural MIDI note-number and pitch (frequency), plus details about loop start and end points, if used. For `loadUsingSfzFile()` allows all this "metadata" to be encoded in a SFZ file, using a simple plain-text format which is easy to understand and edit manually.

The mapping of MIDI (note number, velocity) pairs to samples is done using some internal lookup tables, which can be populated in one of two ways:

1. When your metadata includes min/max note-number and velocity values for all samples, call `buildKeyMap()` to build a full key/velocity map.
2. If you only have note-numbers for each sample, call `buildSimpleKeyMap()` to map each MIDI note-number (at any velocity) to the *nearest available* sample.

**Important:** Before loading a new group of samples, you must call `unloadAllSamples()`. Otherwise, the new samples will be loaded *in addition* to the already-loaded ones. This wastes memory and worse, newly-loaded samples will usually not sound at all, because the sampler simply plays the first matching sample it finds.

### Sample descriptors
When using `loadRawSampleData()` and `loadCompressedSampleFile()` to load individual samples, you will need to create instances of one of three Swift structure types as follows.

The structures are defined as C structs in *Sampler_Typedefs.h* (which lives in the *AudioKit/Core/DunneCore/Sampler* folder in the main AudioKit repo). This file is simple enough to reproduce here:

    typedef struct
    {
        int noteNumber;
        float noteHz;
        
        int min_note, max_note;
        int min_vel, max_vel;
        
        bool bLoop;
        float fLoopStart, fLoopEnd;
        float fStart, fEnd;
    
    } SampleDescriptor;
    
    typedef struct
    {
        SampleDescriptor sd;
        
        float sampleRateHz;
        bool bInterleaved;
        int nChannels;
        int nSamples;
        float *pData;
    
    } SampleDataDescriptor;
    
    typedef struct
    {
        SampleDescriptor sd;
        
        const char* path;
        
    } SampleFileDescriptor;

By the miracle of Swift/Objective-C bridging (see [Using Swift with Cocoa and Objective-C](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html)), each of these three structures is accessible from Swift as a similarly-named class, which you can create by simply providing values for all the properties, as you'll see in the examples below.

### SampleDataDescriptor and loadRawSampleData()

*SampleDataDescriptor*, which is required when calling `loadRawSampleData()`, has an *SampleDescriptor* property (as described above) plus several additional properties to provide all the information **Sampler** needs about the sample:

* *sampleRateHz* is the sampling rate at which the sample data were acquired. If the sampler needs to play back the sample at a different rate, it will need to scale its playback rate based on the ratio of the two rates.
* *nChannels* will be 1 if the sample is monophonic, or 2 if stereo. Note the sampler can play back mono samples as stereo; it simply plays the same data to both output channels. (In the reverse case, only the Left channel data will sound.)
* *bInterleaved* should be set *true* only for stereo samples represented in memory as Left1, Right1, Left2, Right2, etc. Set *false* for mono samples, or non-interleaved stereo samples where all the Left samples come first, followed by all the Right samples.
* *pSamples* is a pointer to the raw sample data; it has the slightly-scary Swift type *UnsafeMutablePointer\<Float\>*.

Here's an example of creating a sample programmatically in Swift, and loading it using `loadRawSampleData()`:

    var myData = [Float](repeating: 0.0, count: 1000)
    for i in 0..<1000 {
        myData[i] = sin(2.0 * Float(i)/1000 * Float.pi)
    }
    let sampleRate = Float(Settings.sampleRate)
    let desc = SampleDescriptor(noteNumber: 69,
                                      noteHz: sampleRate/1000,
                                    min_note: -1,
                                    max_note: -1,
                                     min_vel: -1,
                                     max_vel: -1,
                                       bLoop: true,
                                  fLoopStart: 0,
                                    fLoopEnd: 1,
                                      fStart: 0,
                                        fEnd: 0)
    let ptr = UnsafeMutablePointer<Float>(mutating: myData)
    let ddesc = SampleDataDescriptor(sd: desc,
                             sampleRateHz: sampleRate,
                             bInterleaved: false,
                                nChannels: 1,
                                 nSamples: 1000,
                                    pData: ptr)
    sampler.loadRawSampleData(sdd: ddesc)
    sampler.setLoop(thruRelease: true)
    sampler.buildSimpleKeyMap()

A few points to note about this example:

* We get the scary-typed pointer by calling the pointer type's `init(mutating:)` function
* `Settings.sampleRate` provides the current audio sampling rate
* Since we have only one note, the `noteNumber` can be anything
* We can set `min_note` etc. to -1, because we call `buildSimpleKeyMap()` not `buildKeyMap()`
* `fLoopStart` and `fLoopEnd` are normally sample counts (i.e., we could specify 0.0 and 999.0 to loop over the whole sample), but values between 0 and 1 are interpreted as *fractions* of the full sample length. Hence we can just use 0 to mean "start of the sample" and 1 to mean "end of the sample".
* setting `fEnd` to 0 also means "end of the sample"
* To ensure the sampler keeps looping even after each note is released (very important with such short samples), we call `setLoop(thruRelease: true)`.

### SampleFileDescriptor and loadCompressedSampleFile()
*SampleFileDescriptor*, used in calls to `loadCompressedSampleFile()` is very simple. Like *SampleDataDescriptor*, it has an *SampleDescriptor* property, to which it simply adds a `String` property `path`. Here's an example of using `loadCompressedSampleFile()`, taken from the Sampler demo program:

    private func loadCompressed(baseURL: URL,
                             noteNumber: MIDINoteNumber,
                             folderName: String,
                             fileEnding: String,
                               min_note: Int32 = -1,
                               max_note: Int32 = -1,
                               min_vel: Int32 = -1,
                               max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let freq = float(PolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
        let sd = SampleDescriptor(noteNumber: Int32(noteNumber),
                                        noteHz: freq,
                                      min_note: min_note,
                                      max_note: max_note,
                                       min_vel: min_vel,
                                       max_vel: max_vel,
                                         bLoop: true,
                                    fLoopStart: 0.2,
                                      fLoopEnd: 0.3,
                                        fStart: 0.0,
                                          fEnd: 0.0)
        let fdesc = SampleFileDescriptor(sd: sd, path: fileURL.path)
        sampler.loadCompressedSampleFile(sfd: fdesc)
    }

Note in the last line of the code above, `sampler` is a **Sampler** instance. See the *Conductor.swift* file in the SamplerDemo macOS example for more context.



## Sampler Audio Unit and Node

Implementation of the **Sampler** Swift class, which is built on top of the similarly-named C++ Core class.

There are *four distinct layers of code* here, as follows.

### SamplerDSP
**SamplerDSP** is a C++ class which inherits from the Core *Sampler* as well as **DSPBase**, one of the primary AudioKit base classes for DSP code.

The implementation resides in a `.mm` file rather than a `.cpp` file, because it also contains several Objective-C accessor functions which facilitate bridging between Swift code above and C++ code below.

Hence there are *two separate code layers* here: the **SamplerDSP** class below and the Objective-C accessor functions above.

### SamplerAudioUnit
The Swift **SamplerAudioUnit** class is the next level above the **Sampler** class and its Objective-C accessor functions. It wraps the DSP code within a *version-3 Audio Unit* object which exposes several dynamic *parameters* and can be connected to other Audio Unit objects to process the audio stream it generates.

## Sampler and extensions
The highest level **Sampler** Swift class wraps the Audio Unit code within an AudioKit **Node** object, which facilitates easy interconnection with other AudioKit nodes, and exposes the underlying Audio Unit parameters as Swift *properties*.

The **Sampler** class also includes utility functions to assist with loading sample data into the underlying C++ `Sampler` object (using **AVAudioFile**).

Additional utility functions are implemented in separate files as Swift *extensions*. `Sampler+SFZ.swift` adds a rudimentary facility to load whole sets of samples by interpreting a [SFZ file](https://en.wikipedia.org/wiki/SFZ_(file_format)).


## Preparing sample sets for Sampler

Preparing sets of samples for **Sampler** involves four steps:

1. Preparing (or acquiring) sample files
2. Compressing sample files
3. Creating a SFZ metadata file
4. Testing

This document describes the process of preparing a set of demonstration samples, starting with the sample files included with [ROMPlayer](https://github.com/AudioKit/ROMPlayer).

You can download the finished product from [this link](http://audiokit.io/downloads/ROMPlayerInstruments.zip).

### Preparing/acquiring sample files
The demo samples were recorded and prepared by Matthew Fecher from a Yamaha TX81z hardware FM synthesizer module, using commercial sampling software called [SampleRobot](http://www.samplerobot.com). If you have *MainStage 3* on the Mac, you can use its excellent *autosampler* function instead.

**Important:** If you're planning to work with existing samples, or capture the output from a sample-based instrument, *give careful consideration to copyright issues*. See Matt Fecher's excellent summary [What Sounds Can You Use in your App?](https://github.com/AudioKit/ROMPlayer#what-sounds-can-you-use-in-your-app) *Be very careful with SoundFont files you find on the Internet.* Many are marked "public domain", but actually consist of unlicensed, illegally copied content. While such things are fine for your own personal use, distributing them publicly with your name attached (e.g. in an iOS app on the App Store) can land you in serious legal trouble.

Turning a set of rough digital recordings into cleanly-playing, looping samples is a complex process in itself, which is beyond the scope of this document. For a quick introduction, see [The Secrets of Great Sounding Samples](http://tweakheadz.com/sampling-tips/). For in-depth exploration, look into YouTube videos by [John Lemkuhl aka PlugInGuru](https://www.youtube.com/user/thepluginguru), in particular [this one](https://youtu.be/o7rL38xrRSE), [this one](https://youtu.be/qPbf5nNyQYo) and [this one](https://youtu.be/Bx9PC8JJNGg).

### Sample file compression
**Sampler** reads `.wv` files compressed using the open-source [Wavpack](http://www.wavpack.com) software. On the Mac, you must first install the Wavpack command-line tools. Then you can use the following Python 2 script to compress a whole folder-full of `.wav` files:

```python
import os, subprocess

for wav in os.listdir('.'):
  if os.path.isfile(wav) and aif.endswith('.wav'):
    print 'converting', wav
    name = wav[:-4]
    wv = name + '.wv'
    subprocess.call(['/usr/local/bin/wavpack', '-q', '-r', '-b24', wav])
    #os.remove(wav)
```
Uncomment the last line if you're sure you want to delete WAV files after converting them.

Note that the `wavpack` command-line program does not recognize the `.aif` file format, which is too bad because that's what *MainStage 3*'s autosampler produces. However, we can use the `afconvert` command-line utility built into macOS to convert `.aif` files to `.wav` like this:

```python
import os, subprocess

for aif in os.listdir('.'):
  if os.path.isfile(aif) and aif.endswith('.aif'):
    print 'converting', aif
    name = aif[:-4]
    wav = name + '.wav'
    wv = name + '.wv'
    subprocess.call(['/usr/bin/afconvert', '-f', 'WAVE', '-d', 'LEI24', aif, wav])
    subprocess.call(['/usr/local/bin/wavpack', '-q', '-r', '-b24', wav])
    os.remove(wav)
    #os.remove(aif)
```

### Creating a SFZ metadata file
Mapping of MIDI (note-number, velocity) pairs to sample files requires additional data, for which **Sampler** uses a simple subset of the [SFZ format](https://en.wikipedia.org/wiki/SFZ_(file_format)). SFZ is essentially a text-based, open-standard alternative to the proprietary [SoundFont](https://en.wikipedia.org/wiki/SoundFont) format.

In addition to key-mapping, SFZ files can also contain other important metadata such as loop-start and -end points for each sample file.

The full SFZ standard is very rich, but at the time of writing, **Sampler**'s SFZ import capability is limited to key mapping and loop metadata only.


### How the demo SFZ files were made
Matt originally provided `.esx` metadata files for use by Apple's ESX24 Sampler plugin included with Logic Pro X. These files use a proprietary binary format and are notoriously difficult to work with.

Fortunately, KVR user [vonRed](https://www.kvraudio.com/forum/memberlist.php?mode=viewprofile&u=134002) has provided a free tool called [esxtosfz.py](https://www.kvraudio.com/forum/viewtopic.php?t=399035), which does a reasonable job of reading `.esx` files and outputting equivalent `.sfz` files. *Note this tool is written in Python 3, which is not installed by default on Macs, but is [available here](https://www.python.org/downloads/mac-osx/).*

The following Python 2 script will convert all `.esx` files in a folder to `.sfz` format:

```python
import os, subprocess

for exs in os.listdir('.'):
  if os.path.isfile(exs) and exs.endswith('.exs'):
    print 'converting', exs
    sfz = exs[:-4] + '.sfz'
    subprocess.call(['/usr/local/bin/python3', '/Users/shane/exs2sfz.py', exs, sfz, 'samples'])
    #os.remove(exs)
```

### Other methods to create SFZ files
Since SFZ files are simply plain-text files, you can use an ordinary text editor to create them.

At the other end of the scale, a company called Chicken Systems sells a very powerful tool called [Translator](http://www.chickensys.com/products2/translator/), which can convert both sample and metadata to and from a huge list of professional formats, including ESX24 (Apple), SoundFont (SF2 and SFZ), Kontakt 5 (Native Instruments), and many more. The full version costs $149 (USD), but if you're only interested in converting to SFZ, you can buy the "Special Edition" for just $79.

### Scripts for MainStage 3 Autosampler
The autosampler built into Apple's *MainStage 3* produces AIFF-C audio files and an EXS24 metadata file, in a newer format than vonRed's `esxtosfz.py` script can handle. However, all the necessary details are actually encoded right in the `.aif` sample files. The following Python script uses a simplistic parsing technique to pull the necessary numbers out of a set of `.aif` files and create a corresponding `.sfz` file:

```python
import sys, os
import struct
 
if len(sys.argv) != 3:
    print('usage: python parse.py <dirname> <noteoffset>')
    exit(0)
 
baseName = sys.argv[1]
noteOffset = int(sys.argv[2])
 
itemList = list()
for filename in os.listdir(baseName):
    if filename.endswith('.aif'):
        noteName = filename.split('-')[1][:-4]
        octaveNumber = int(noteName[-1])
        letters = noteName[:-1]
        noteNumber = 12
        if letters == 'F#':
            noteNumber += 6
        noteNumber += octaveNumber * 12 + noteOffset
        itemList.append((noteNumber, noteName))
 
sfz = open(baseName + '.sfz', 'w')
 
itemList.sort()
for (noteNumber, noteName) in itemList:
    filePath = os.path.join(baseName, baseName + '-' + noteName + '.aif')
    data = open(filePath, 'rb').read(100)
    start = struct.unpack_from('>I', data, 0x32)[0]
    end = struct.unpack_from('>I', data, 0x3E)[0]
    loopStart = struct.unpack_from('>I', data, 0x48)[0]
    loopEnd = struct.unpack_from('>I', data, 0x58)[0]
    if noteNumber == itemList[0][0]:
        sfz.write('<group>lokey=0 hikey=%d pitch_keycenter=%d pitch_keytrack=100\n' % (noteNumber+3, noteNumber))
    elif noteNumber == itemList[-1][0]:
        sfz.write('<group>lokey=%d hikey=127 pitch_keycenter=%d pitch_keytrack=100\n' % (noteNumber-2, noteNumber))
    else:
        sfz.write('<group>lokey=%d hikey=%d pitch_keycenter=%d pitch_keytrack=100\n' % (noteNumber-2, noteNumber+3, noteNumber))
    sfz.write('    <region> lovel=000 hivel=127')
    if start > 0:
        sfz.write(' offset=%d' % start)
    if end > 0:
        sfz.write(' end=%d' % end)
    if loopStart > 0 and loopEnd > 0:
        sfz.write(' loop_mode=loop_sustain loop_start=%d loop_end=%d' % (loopStart, loopEnd))
    sfz.write(' sample=%s\n' % filePath)
 
sfz.close()
```

Note this script relies on the standard Python module [struct](https://docs.python.org/2/library/struct.html) to parse binary data. *It won't work with all AIFF files*, though, because it doesn't actually understand the [AIFF format](http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AIFF/AIFF.html). The following is a preliminary version of a new Python 2.7 script which does a better job of parsing an individual AIFF file:

```python
import chunk, struct
 
def readCOMM(chk):
    print 'COMM', chk.getsize()
    data = chk.read()
    channels, frames, bitsPerSample, exp, mant = struct.unpack('>hIhhQ', data)
    print channels, 'channels,', frames, 'frames,', bitsPerSample, 'bits/sample',
    # simplified conversion of 80-bit SANE float, using 1st 32 bits of mantissa
    sampleRate = ((mant >> 32) / pow(2.0, 31)) * pow(2.0, exp - 16383)
    print sampleRate, 'samples/sec'
 
def readMARK(chk):
    print 'MARK', chk.getsize()
    count = struct.unpack('>h', chk.read(2))[0]
    for i in xrange(count):
        id, position, charCount = struct.unpack('>hIB', chk.read(7))
        name = chk.read(charCount)
        print '  ', id, position, name
 
def loopModeName(mode):
    if mode == 0:
        return 'NoLoop'
    elif mode == 1:
        return 'FwdLoop'
    elif mode == 2:
        return 'FwdRev'
    else:
        return '?mode?', mode
 
def readINST(chk):
    print 'INST', chk.getsize()
    baseNote, detune, lowNote, highNote, lowVel, highVel, gain = struct.unpack('>bbbbbbh', chk.read(8))
    susLoopMode, susloopStart, susLoopEnd = struct.unpack('>hhh', chk.read(6))
    relLoopMode, relloopStart, relLoopEnd = struct.unpack('>hhh', chk.read(6))
    print '  note', baseNote, 'detune', detune,
    print 'noteRange', lowNote, '-', highNote, 
    print 'velRange', lowVel, '-', highVel
    print '  susLoop', loopModeName(susLoopMode), susloopStart, susLoopEnd
    print '  relLoop', loopModeName(relLoopMode), relloopStart, relLoopEnd
 
file = open('X50 Brothers Acoustic-C4.aif')
chk = chunk.Chunk(file)
name = chk.getname()
if name != b'FORM':
    print "File starts with '%s' not 'FORM'" % name
    exit()
size = chk.getsize()
kind = chk.read(4)
print name, size, kind
 
while 1:
    try:
        chk = chunk.Chunk(file)
    except EOFError:
        break
    name = chk.getname()
    if name == b'COMM':
        readCOMM(chk)
    elif name == b'MARK':
        readMARK(chk)
    elif name == b'INST':
        readINST(chk)
    else:
        size = chk.getsize()
        print name, size
    chk.skip()
```

This script makes use of the [chunk](https://docs.python.org/2/library/chunk.html) Python library, together with specific data gleaned from the [AIFF-C format specifications](http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AIFF/AIFF.html).
The obvious next step is to combine elements of both scripts, to produce a better version of the first one.

## Simple Example of a simple SFZ file

If your sampling needs are not very complex, as in, you simply just need to load your `Sampler` with a variety samples, here is an example of a working SFZ File:

```
<control>
default_path=samples/
<global>
<group>key=33
<region> sample=A1.wv
<group>key=34
<region> sample=A#1.wv
<group>key=35
<region> sample=B1.wv
<group>key=36
<region> sample=C2.wv
<group>key=37
<region> sample=C#2.wv
<group>key=38
<region> sample=D2.wv
<group>key=39
<region> sample=D#2.wv
<group>key=40
<region> sample=E2.wv
<group>key=41
<region> sample=F2.wv
<group>key=42
<region> sample=F#2.wv
<group>key=43
<region> sample=G2.wv
<group>key=44
<region> sample=G#2.wv
<group>key=45
<region> sample=A2.wv
<group>key=46
<region> sample=A#2.wv
<group>key=47
<region> sample=B2.wv
<group>key=48
<region> sample=C3.wv
<group>key=49
<region> sample=C#3.wv
<group>key=50
<region> sample=D3.wv
<group>key=51
<region> sample=D#3.wv
<group>key=52
<region> sample=E3.wv
<group>key=53
<region> sample=F3.wv
<group>key=54
<region> sample=F#3.wv
<group>key=55
<region> sample=G3.wv
<group>key=56
<region> sample=G#3.wv
<group>key=57
<region> sample=A3.wv
<group>key=58
<region> sample=A#3.wv
<group>key=59
<region> sample=B3.wv
<group>key=60
<region> sample=C4.wv
<group>key=61
<region> sample=C#4.wv
<group>key=62
<region> sample=D4.wv
<group>key=63
<region> sample=D#4.wv
<group>key=64
<region> sample=E4.wv
<group>key=65
<region> sample=F4.wv
<group>key=66
<region> sample=F#4.wv
<group>key=67
<region> sample=G4.wv
<group>key=68
<region> sample=G#4.wv
<group>key=69
<region> sample=A4.wv
<group>key=70
<region> sample=A#4.wv
<group>key=71
<region> sample=B4.wv
<group>lokey=72 hikey=80 pitch_keycenter=72
<region> sample=C5.wv
```

This SFZ file is an example of a piano sampler with samples matched note for note in most octaves. Let's go over from top to bottom:

`<control>`

This is a necessary SFZ keyword to denote that this is indeed a SFZ file.

`default_path=samples/`

The path in which the samples you are describing in the SFZ file reside. In this example SFZ file, we have a folder named `samples` that is in the same directory as the SFZ file. You may name your folder any name, as long as it is described correctly in the SFZ file. *You will need to ensure that your folder of samples and the path is described correctly. If your SFZ file resides in a different directory, please be sure find the correct path for the folder of samples so that the SFZ can correctly find them* 

`<group>key=33`

For more information on the `<group>` SFZ keyword, please read [here](https://sfzformat.com/headers/group). Here we are preparing the MIDI note 33 to be assigned to a sample.

`<region> sample=A1.wv>` 

For more information on the `<region>` SFZ keyword, please read [here](https://sfzformat.com/headers/region).

Here we are assigning a specific sample you have collected to the above group/key. 

So now with:
`<group>key=33`
`<region> sample=A1.wv>`

Our sampler will assign key 33 to the sample `A1.wv`.

In this example file, we are just continuing to assign 1 to 1 keys to samples.

Lets look at the last 2 lines:

`<group>lokey=72 hikey=80 pitch_keycenter=72
<region> sample=C5.wv`

`lokey` and `hikey` allows us to use one sample to map to multiple keys or MIDI notes. `pitch_keycenter` tells us where to center the key or MIDI note for the sample. In these two lines, we are assigning the sample `C5.wv` to MIDI notes (or keys) 72 *through* 80. The sampler will pitch shift the sample in order to accommodate the higher/lower notes. Be aware that small amounts of pitch shifting will be hard to discern, but anything past a Perfect 5th (7 semitones) will start to exhibit pitch shifting artifacts. Check out more information on [`lokey` and `hikey`](https://sfzformat.com/opcodes/hikey), and [`pitch_keycenter`](https://sfzformat.com/opcodes/pitch_keycenter).

**IMPORTANT** 

**In order for the Audiokit `Sampler` to load your samples correctly, in your `<region>` declarations, the sample assignment MUST BE THE LAST ELEMENT of your `<region>` declarations.**

`<region>` has other opcodes you can use such as `lovel` and `hivel`, if you do not place your `sample=YOURSAMPLENAME.YOURFILEFORMAT` as the last element in the `<region>` line, the samples will not load!

### Testing
Whatever methods you use to create samples and metadata files, it's important to test, test, test, to make sure things are working the way you want.

### Going further
The subject of preparing sample sets is deep and complex, and this article has barely scratched the surface. We hope to provide additional online resources as time goes on, especially as **Sampler**'s implementation expands and changes. Interested users, especially those with practical experience to share, are encouraged to get in touch with the AudioKit team to help with this process.
