# Preparing sample sets for Sampler

Preparing sets of samples for **Sampler** involves four steps:

1. Preparing (or acquiring) sample files
2. Compressing sample files
3. Creating a SFZ metadata file
4. Testing

This document describes the process of preparing a set of demonstration samples, starting with the sample files included with [ROMPlayer](https://github.com/AudioKit/ROMPlayer).

You can download the finished product from [this link](http://audiokit.io/downloads/ROMPlayerInstruments.zip).

## Preparing/acquiring sample files
The demo samples were recorded and prepared by Matthew Fecher from a Yamaha TX81z hardware FM synthesizer module, using commercial sampling software called [SampleRobot](http://www.samplerobot.com). If you have *MainStage 3* on the Mac, you can use its excellent *autosampler* function instead.

**Important:** If you're planning to work with existing samples, or capture the output from a sample-based instrument, *give careful consideration to copyright issues*. See Matt Fecher's excellent summary [What Sounds Can You Use in your App?](https://github.com/AudioKit/ROMPlayer#what-sounds-can-you-use-in-your-app) *Be very careful with SoundFont files you find on the Internet.* Many are marked "public domain", but actually consist of unlicensed, illegally copied content. While such things are fine for your own personal use, distributing them publicly with your name attached (e.g. in an iOS app on the App Store) can land you in serious legal trouble.

Turning a set of rough digital recordings into cleanly-playing, looping samples is a complex process in itself, which is beyond the scope of this document. For a quick introduction, see [The Secrets of Great Sounding Samples](http://tweakheadz.com/sampling-tips/). For in-depth exploration, look into YouTube videos by [John Lemkuhl aka PlugInGuru](https://www.youtube.com/user/thepluginguru), in particular [this one](https://youtu.be/o7rL38xrRSE), [this one](https://youtu.be/qPbf5nNyQYo) and [this one](https://youtu.be/Bx9PC8JJNGg).

## Sample file compression
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

## Creating a SFZ metatdata file
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
The autosampler built into Apple's *MainStage 3* produces AIFF-C audio fils and an EXS24 metadata file, in a newer format than vonRed's `esxtosfz.py` script can handle. However, all the necessary details are actually encoded right in the `.aif` sample files. The following Python script uses a simplistic parsing technique to pull the necessary numbers out of a set of `.aif` files and create a corresponding `.sfz` file:

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
    sfz.write('	<region> lovel=000 hivel=127')
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

This is a necessary SFZ keyword to deonte that this is indeed a SFZ file.

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

`lokey` and `hikey` allows us to use one sample to map to multiple keys or MIDI notes. `pitch_keycenter` tells us where to center the key or MIDI note for the sample. In these two lines, we are assigning the sample `C5.wv` to MIDI notes (or keys) 72 *through* 80. The sampler will pitch shift the sample in order to accomdate the higher/lower notes. Be aware that small amounts of pitch shifting will be hard to descern, but anything past a Perfect 5th (7 semitones) will start to exhibit pitch shifting artifacts. Check out more information on [`lokey` and `hikey`](https://sfzformat.com/opcodes/hikey), and [`pitch_keycenter`](https://sfzformat.com/opcodes/pitch_keycenter).

**IMPORTANT** 

**In order for the Audiokit `Sampler` to load your samples correctly, in your `<region>` declarations, the sample assignment MUST BE THE LAST ELEMENT of your `<region>` declarations.**

`<region>` has other opcodes you can use such as `lovel` and `hivel`, if you do not place your `sample=YOURSAMPLENAME.YOURFILEFORMAT` as the last element in the `<region>` line, the samples will not load!

## Testing
Whatever methods you use to create samples and metadata files, it's important to test, test, test, to make sure things are working the way you want.

## Going further
The subject of preparing sample sets is deep and complex, and this article has barely scratched the surface. We hope to provide additional online resources as time goes on, especially as **Sampler**'s implementation expands and changes. Interested users, especially those with practical experience to share, are encouraged to get in touch with the AudioKit team to help with this process.
