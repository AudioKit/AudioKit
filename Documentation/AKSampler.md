# AKSampler
**AKSampler** is a new, polyphonic sample-playback engine built from scratch in C++. Because the base C++ code is platform-independent, it is also available as an Audio Unit v2 plug-in (which can be loaded into e.g. *Logic Pro X*), and even on Windows as a *VST2* plug-in, for use in Windows DAWs such as Steinberg's *Cubase*. ("VST" is a registered trade mark of [Steinberg Media Technologies GmbH](https://www.steinberg.net/en/company/developers.html).) You'll find these projects under the *Developer* folder in the main AudioKit repo.

## AKSampler vs AKAppleSampler

In earlier versions of AudioKit, the name **AKSampler** referred to the module now called **AKAppleSampler**.

**AKAppleSampler** and its companion class **AKMIDISampler** are wrappers for Apple's *AUSampler* Audio Unit, an exceptionally powerful polyphonic, multi-timbral sampler instrument which is built-in to both macOS and iOS. Unfortunately, *AUSampler* is far from perfect and not properly documented. The new **AKSampler** is an attempt to provide an open-source alternative.

**AKSampler** is nowhere near as powerful as *AUSampler*. If your app depends on **AKAppleSampler** (formerly called AKSampler) or the **AKMIDISampler** wrapper class, you should continue to use it.

## AKSampler vs AKSamplePlayer

If your app only needs to load and play back samples individually, without a lot of pitch-shifting, you should also consider using **AKSamplePlayer**, which provides more precise and dynamic control of looping.

## Loading samples
**AKSampler** provides three distinct mechanisms for loading samples:

1. `loadRawSampleData()` allows use of sample data already in memory, e.g. data generated programmatically or read using custom file-reading code.
2. `loadAKAudioFile()` allows reading standard file formats like WAV, CAF, AIFF, etc.  from an instance of **AKAudioFile**. `loadCompressedSampleFile()` allows reading `.wv` files which have been compressed using [Wavpack](http://www.wavpack.com/).
3. `loadUsingSfzFile()` loads entire sets of samples by interpreting a simplistic subset of the "SFZ" soundfont file format.

`loadRawSampleData()`, `loadAKAudioFile()`, and `loadCompressedSampleFile()` all take a "descriptor" argument (see next section below), whose many member variables define details like the sample's natural MIDI note-number and pitch (frequency), plus details about loop start and end points, if used. For `loadUsingSfzFile()` allows all this "metadata" to be encoded in a SFZ file, using a simple plain-text format which is easy to understand and edit manually.

The mapping of MIDI (note number, velocity) pairs to samples is done using some internal lookup tables, which can be populated in one of two ways:

1. When your metadata includes min/max note-number and velocity values for all samples, call `buildKeyMap()` to build a full key/velocity map.
2. If you only have note-numbers for each sample, call `buildSimpleKeyMap()` to map each MIDI note-number (at any velocity) to the *nearest available* sample.

**Important:** Before loading a new group of samples, you must call `unloadAllSamples()`. Otherwise, the new samples will be loaded *in addition* to the already-loaded ones. This wastes memory and worse, newly-loaded samples will usually not sound at all, because the sampler simply plays the first matching sample it finds.

## Sample descriptors
When using `loadRawSampleData()`, `loadAKAudioFile()`, and `loadCompressedSampleFile()` to load individual samples, you will need to create instances of one of three Swift structure types as follows.

The structures are defined as C structs in *AKSampler_Typedefs.h* (which lives in the *AudioKit/Core/AudioKitCore/Sampler* folder in the main AudioKit repo). This file is simple enough to reproduce here:

	typedef struct
	{
	    int noteNumber;
	    float noteHz;
	    
	    int min_note, max_note;
	    int min_vel, max_vel;
	    
	    bool bLoop;
	    float fLoopStart, fLoopEnd;
	    float fStart, fEnd;
	
	} AKSampleDescriptor;
	
	typedef struct
	{
	    AKSampleDescriptor sd;
	    
	    float sampleRateHz;
	    bool bInterleaved;
	    int nChannels;
	    int nSamples;
	    float *pData;
	
	} AKSampleDataDescriptor;
	
	typedef struct
	{
	    AKSampleDescriptor sd;
	    
	    const char* path;
	    
	} AKSampleFileDescriptor;

By the miracle of Swift/Objective-C bridging (see [Using Swift with Cocoa and Objective-C](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html)), each of these three structures is accessible from Swift as a similarly-named class, which you can create by simply providing values for all the properties, as you'll see in the examples below.

### AKSampleDescriptor and loadAKAudioFile()

*AKSampleDescriptor* is the simplest and most fundamental of the three descriptor classes; the other two encapsulate an instance of this struct and add one or more additional properties. Only the first two properties, *noteNumber* and *noteHz* are required.

* *noteNumber* is a MIDI note number, 0-127 where 60 represents middle C on the piano
* *noteHz* is the corresponding note frequency in Hertz. In an AudioKit program, if all you have is the note number, you can use `AKPolyphonicNode.tuningTable.frequency(forNoteNumber:)` to look up the standard frequency for that note.

The *min_note*, *max_note*, *min_vel*, and *max_vel* properties are used by `buildKeyMap()` to populate the sampler's internal lookup tables for selecting samples based on MIDI (note, velocity) pairs. If you don't have data for these members, you can set all four to -1, and call `buildSimpleKeyMap()` instead.

Here's an example of how to load a single sample from a WAV file using `loadAKAudioFile()`, which requires creating an instance of *AKSampleDescriptor*:

    let path = "/Users/shane/Desktop/AKWF Samples/AKWF_bw_sawbright/AKWF_bsaw_0005.wav"
    let furl = URL(fileURLWithPath: path)
    let file = try AKAudioFile(forReading: furl)
    let desc = AKSampleDescriptor(noteNumber: 26,
                                      noteHz: 44100.0/600,
                                    min_note: 0,
                                    max_note: 127,
                                     min_vel: 0,
                                     max_vel: 127,
                                       bLoop: true,
                                  fLoopStart: 0.0,
                                    fLoopEnd: 1.0,
                                      fStart: 0.0,
                                        fEnd: 0.0)
       sampler.loadAKAudioFile(sd: desc, file: file)

See the following sections for notes about setting the `fLoopStart`, `fLoopEnd`, `fStart` and `fEnd` properties.

### AKSampleDataDescriptor and loadRawSampleData()

*AKSampleDataDescriptor*, which is required when calling `loadRawSampleData()`, has an *AKSampleDescriptor* property (as described above) plus several additional properties to provide all the information **AKSampler** needs about the sample:

* *sampleRateHz* is the sampling rate at which the sample data were acquired. If the sampler needs to play back the sample at a different rate, it will need to scale its playback rate based on the ratio of the two rates.
* *nChannels* will be 1 if the sample is monophonic, or 2 if stereo. Note the sampler can play back mono samples as stereo; it simply plays the same data to both output channels. (In the reverse case, only the Left channel data will sound.)
* *bInterleaved* should be set *true* only for stereo samples represented in memory as Left1, Right1, Left2, Right2, etc. Set *false* for mono samples, or non-interleaved stereo samples where all the Left samples come first, followed by all the Right samples.
* *pSamples* is a pointer to the raw sample data; it has the slightly-scary Swift type *UnsafeMutablePointer\<Float\>*.

Here's an example of creating a sample programmatically in Swift, and loading it using `loadRawSampleData()`:

    var myData = [Float](repeating: 0.0, count: 1000)
    for i in 0..<1000 {
        myData[i] = sin(2.0 * Float(i)/1000 * Float.pi)
    }
    let sampleRate = Float(AKSettings.sampleRate)
    let desc = AKSampleDescriptor(noteNumber: 69,
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
    let ddesc = AKSampleDataDescriptor(sd: desc,
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
* `AKSettings.sampeRate` provides the current audio sampling rate
* Since we have only one note, the `noteNumber` can be anything
* We can set `min_note` etc. to -1, because we call `buildSimpleKeyMap()` not `buildKeyMap()`
* `fLoopStart` and `fLoopEnd` are normally sample counts (i.e., we could specify 0.0 and 999.0 to loop over the whole sample), but values between 0 and 1 are interpreted as *fractions* of the full sample length. Hence we can just use 0 to mean "start of the sample" and 1 to mean "end of the sample".
* setting `fEnd` to 0 also means "end of the sample"
* To ensure the sampler keeps looping even after each note is released (very important with such short samples), we call `setLoop(thruRelease: true)`.

## AKSampleFileDescriptor and loadCompressedSampleFile()
*AKSampleFileDescriptor*, used in calls to `loadCompressedSampleFile()` is very simple. Like *AKSampleDataDescriptor*, it has an *AKSampleDescriptor* property, to which it simply adds a `String` property `path`. Here's an example of using `loadCompressedSampleFile()`, taken from the AKSampler demo program:

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
        let freq = float(AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
        let sd = AKSampleDescriptor(noteNumber: Int32(noteNumber),
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
        let fdesc = AKSampleFileDescriptor(sd: sd, path: fileURL.path)
        sampler.loadCompressedSampleFile(sfd: fdesc)
    }

Note in the last line of the code above, `sampler` is an **AKSampler** instance. See the *Conductor.swift* file in the AKSamplerDemo macOS example for more context.
