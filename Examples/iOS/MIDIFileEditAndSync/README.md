# MIDI File Edit and Sync

This is an example project which demonstrates:

- Creating new sequences from MIDI files
- Adding tracks from other MIDI files to an existing sequence (i.e., syncing multiple MIDI files to the same sequencer)
- Accessing and editing MIDI note data using AKSequencer and AKMusicTrack
- Exporting MIDI files from the contents of AKSequencer 


## Creating a new sequence from a MIDI file

AKSequencer can be initialized by either a filename or URL, or an existing AKSequencer can have a new internal sequence created by calling ```loadMIDIFile()```.

- There is considerable variety in the anatomy of MIDI files in the wild.  Many, but not all, contain a 'tempo track' as the first track with no MIDINoteMessages, but often extendedTempo or meta events. The underlying sequencer will respond to the tempo events, so you might want to clear or delete this track.  Checking the size of the ```AKMusicTrack.getMIDINoteData()``` array will tell you if the track has no MIDI note messages.
- When you create a new sequence with ```loadMIDIFile()```, you will need to set all of the destinations for the AKMusicTracks, e.g., ```sequencer.setGlobalMIDIOutput(midiNode.midiIn)```.
- You will also need to explicitly set the length of the new sequence, then possibly re-assert looping behaviour (```enableLooping()```).  Apple's underlying sequencer makes some odd assumptions about looping lengths based on the end of the last note in the track. In the example app, I explicitly set the loop length to 4 if it thinks the loop length of a new file is less than 4.

## Adding tracks from a MIDI file to an existing sequencer

Calling ```addMIDIFileTracks()``` will get the MIDINoteMessage data from the new MIDI file and copy them to new tracks in the existing sequencer.  *Only MIDINoteMessage data are copied*.

- You will need to set the MIDI output of the new music tracks (e.g., ```sequencer.setGlobalMIDIOutput(midiNode.midiIn)```). If you try to use ```addMIDIFileTracks()``` without assigning the MIDI output, it will go directly to Apple's very ugly default player.
- Because you are adding new MusicTracks to the sequencer, you will also need to restart the sequencer to get the new tracks to playback.  If you need to be able to add tracks from a MIDI File while the sequencer is playing, you could create empty tracks and assign their MIDI outputs beforehand (i.e., before starting sequencer playback).  AKMusicTrack's ```replaceMIDIData()``` seems to work fairly well while the sequencer is playing (but no promises).  You could follow the same basic steps from AKSequencer's ```addMusicTrackNoteData()``` i.e., create a temp AKSequencer and copy its track data using ```getMIDINoteData()``` and then use the note details with ```replaceMIDIData()``` on your premade tracks. 
- Using AKMusicTrack's ```copyAndMergeTo(musicTrack: AKMusicTrack)``` could also be used on a temp AKSequencer initialized by a MIDI File. It will copy the entire MusicTrack, not only the MIDINoteMessages.
- If you add a track which is longer than your current sequence length, normally your current sequence length *will change automatically to what it thinks is your new track's length*.  AKSequencer's computed variable ```length``` just returns the apparent length of the longest track in the sequence *which may have changed* (you need to be especially careful with this if you are adding tracks with different time signatures).  The ```useExistingSequencerLength``` flag, which is true by default, will keep track of the sequencer length before adding the new tracks, and set them to the original length. Note that it will truncate any notes that go beyond the original length.


## Editing AKMusicTracks

Calling AKMusicTrack's ```getMIDINoteData()``` will return an array of the struct ```AKMIDINoteData```, which contains details of all of the MIDINoteMessages in that track. Changing this array won't directly affect the MusicTrack, but you can edit the contents of this array, and re-write the changes back to the AKMusicTrack:

```
var trackData = sequencer.tracks[0].getMIDINoteData()
// edit contents of trackData
sequencer.tracks[0].replaceMIDINoteData(with: trackData)
```
Note that MIDINoteMessages can be written in any order so if the ```position``` fields of the elements in the array no longer match the sequence of the elements, it doesn't matter.

For a slightly amusing demonstration with the example app, try loading the 'frere-jacques' MIDI file, and putting it into a minor key (use the MIDI filter to lower the Es, As, and Bs by one semi-tone each).

## Exporting MIDI files
Calling AKSequencer's ```genData()``` will create the data that can be easily written to a URL and exported as a MIDI file.

- By default, MIDI files appear in 4/4 time.  If you want the MIDI file to show a different time signature, you can call ```addTimeSignatureEvent()```.  This won't affect sequencer playback (if you want to change the sequence's meter use ```setLength()```).
