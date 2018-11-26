//
//  AKSequencerTrackEngine.m
//  SuperSequencer
//
//  Created by Aurelius Prochazka on 8/11/18. Jeff Cooper remix 201810
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKSequencerTrackEngine.h"
#import <AudioKit/AudioKit-Swift.h>
#import "AKTimelineTap.h"
#import <mach/mach_time.h>

#define NOTEON 0x90
#define NOTEOFF 0x80
#define INITVALUE -1.0
#define MIDINOTECOUNT 128

struct MIDIEvent {
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
    double duration;
};

struct MIDINote {
    struct MIDIEvent noteOn;
    struct MIDIEvent noteOff;
};

@implementation AKSequencerTrackEngine {
    AKTimelineTap *tap;
    MIDIPortRef _midiPort;
    MIDIEndpointRef _midiEndpoint;
    struct MIDIEvent _events[512];
    int _noteCount;
    double _beatsPerSample;
    double _sampleRate;
    double _lengthInBeats;
    uint _playCount;
    uint _maximumPlayCount;
    BOOL _stopAfterCurrentNotes;
    Float64 _startOffset;
    Float64 _lastStartSample; //Used for detecting sequence loopback
    bool _isPlaying;
    AudioUnit _audioUnit;
}

@synthesize maximumPlayCount = _maximumPlayCount;
@synthesize trackIndex = _trackIndex;
@synthesize lengthInBeats = _lengthInBeats;
@synthesize tempo = _tempo;

-(instancetype)init {
    return [self initWith:nil];
}

- (instancetype)initWith:(AKNode *)node{
    return [self initWith:node index:arc4random_uniform(333)];
}

- (instancetype)initWith:(AKNode *)node index:(int)index{
    self = [super init];
    if (self) {
        [self initDefaults:index];
        _audioUnit = [[node avAudioUnit] audioUnit];
        tap = [[AKTimelineTap alloc]initWithNode:node.avAudioNode timelineBlock:[self timelineBlock]];
        tap.preRender = true;
        [self setLengthInBeats:4.0];
        [self setTempo:120];
    }
    return self;
}

-(instancetype)initWith:(MIDIPortRef)midiPort midiEndpoint:(MIDIEndpointRef)midiEndpoint node:(AKNode *)node index:(int)index {
    self = [self initWith:node index:index];
    if (self) {
        _midiPort = midiPort;
        _midiEndpoint = midiEndpoint;
    }
    return self;
}

-(void)initDefaults:(int)index {
    _sampleRate = 44100;
    _noteCount = 0;
    _trackIndex = index;
    _maximumPlayCount = 0; //loop infinitely
    [self resetPlaybackVariables];
}

-(AKTimelineBlock)timelineBlock {
    AudioUnit instrument = _audioUnit;
    struct MIDIEvent *events = _events;
    uint *playCount = &_playCount;
    uint *maximumPlayCount = &_maximumPlayCount;
    int *noteCount = &_noteCount;
    double *beatsPerSample = &_beatsPerSample;
    BOOL *stopAfterCurrentNotes = &_stopAfterCurrentNotes;
    BOOL *isPlaying = &_isPlaying;
    MIDIPortRef *midiPort = &_midiPort;
    MIDIEndpointRef *midiEndpoint = &_midiEndpoint;
    __block Float64 *startOffset = &_startOffset;
    __block Float64 *lastStartSample = &_lastStartSample;

    return ^(AKTimeline         *timeline,
             AudioTimeStamp     *timeStamp,
             UInt32             offset,
             UInt32             inNumberFrames,
             AudioBufferList    *ioData) {

        if (timeStamp->mSampleTime < *lastStartSample) {
            *playCount += 1;
            if (self->_loopCallback != NULL) {
                self->_loopCallback();
            }
            if (*playCount >= *maximumPlayCount && *maximumPlayCount != 0) {
                *stopAfterCurrentNotes = true;
                *isPlaying = false;
            }
        }
        *lastStartSample = timeStamp->mSampleTime;

        if (*startOffset < 0 || timeStamp->mSampleTime == 0) {
            *startOffset = timeStamp->mSampleTime;
        }

        Float64 startSample = timeStamp->mSampleTime - *startOffset;
        Float64 endSample = startSample + inNumberFrames;

        for (int i = 0; i < *noteCount; i++) {
            double triggerTime = events[i].beat / *beatsPerSample;

            if (((startSample <= triggerTime && triggerTime <= endSample)) && *stopAfterCurrentNotes == false)
            {
                int time = triggerTime - startSample + offset;
                if (self->_eventCallback != NULL) {
                    self->_eventCallback(events[i].status, events[i].data1, events[i].data2);
                }
                sendMidiData(instrument, *midiPort, *midiEndpoint,
                             events[i].status, events[i].data1, events[i].data2,
                             time, events[i].beat, i);
            }
        }

        if (*maximumPlayCount != 0 && *playCount >= *maximumPlayCount) {
            [self stop];
            return;
        }
    };
}

void sendMidiData(AudioUnit audioUnit, MIDIPortRef midiPort, MIDIEndpointRef midiEndpoint, UInt8 status, UInt8 data1, UInt8 data2, double offset, double time, int index) {
    //printf("sending: %i %i at %f\n", status, data1, time);
    if (midiPort == 0 || midiEndpoint == 0) {
        MusicDeviceMIDIEvent(audioUnit, status, data1, data2, offset);
    } else {
        MIDIPacketList packetList;
        packetList.numPackets = 1;
        MIDIPacket* firstPacket = &packetList.packet[0];
        firstPacket->length = 3;
        firstPacket->data[0] = status;
        firstPacket->data[1] = data1;
        firstPacket->data[2] = data2;
        firstPacket->timeStamp = offset;
        MIDISend(midiPort, midiEndpoint, &packetList);
    }
}

-(void)debugToConsole:(UInt8)status data1:(UInt8)data1 data2:(UInt8)data2 {
    printf("playing event %u data1:%u data2: %u \n", status, data1, data2);
}

-(void)debugEvents {
    printf("deboog: debuggin sequence\n");
    for (int i = 0; i < _noteCount; i++) {
        printf("deboog: %i - %i - %f \n", _events[i].status, _events[i].data1, _events[i].beat);
    }
}

-(double)lengthInBeats {
    return _lengthInBeats;
}

-(void)setLengthInBeats:(double)lengthInBeats atTime:(AVAudioTime *)audioTime{

    //Store the last beatsPerSample before updating, needed to maintain current beat is running.
    double lastBeatsPerSample = _beatsPerSample;

    AudioTimeStamp timeStamp = [self getValidTimestamp:audioTime];
    _lengthInBeats = lengthInBeats;
    [self resetTimeLine:lastBeatsPerSample atTime:timeStamp];
}

-(void)setTempo:(double)bpm andBeats:(double)beats atTime:(AudioTimeStamp)timeStamp{

    //Store the last beatsPerSample before updating, needed to maintain current beat is running.
    double lastBeatsPerSample = _beatsPerSample;

    //Update new tempo, stored as beatsPerSample.
    double beatsPerSecond = bpm / 60.0;
    _beatsPerSample = beatsPerSecond / _sampleRate;
    _lengthInBeats = beats;
    [self resetTimeLine:lastBeatsPerSample atTime:timeStamp];
}

-(BOOL)isPlaying {
    return _isPlaying;
}

-(double)length {
    return _lengthInBeats;
}

-(void)setTempo:(double)bpm {
    [self setTempo:bpm atTime:nil];
}

-(void)setLengthInBeats:(double)length {
    [self setLengthInBeats:length atTime:nil];
}

-(double)tempo {
    double beatsPerSecond = _beatsPerSample * _sampleRate;
    return beatsPerSecond * 60.0;
}


-(int)addMIDIEvent:(uint8_t)status data1:(uint8_t)data1 data2:(uint8_t)data2 at:(double)beat{
    _events[_noteCount].status = status;
    _events[_noteCount].data1 = data1;
    _events[_noteCount].data2 = data2;
    _events[_noteCount].beat = beat;

    _noteCount += 1;
    return _noteCount - 1;
}

-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat duration:(double)duration {
    double noteOffPosition = (beat + duration);
    while (noteOffPosition >= _lengthInBeats && _lengthInBeats != 0) {
        noteOffPosition -= _lengthInBeats;
    }
    [self addMIDIEvent:NOTEON data1:noteNumber data2:velocity at:beat];
    [self addMIDIEvent:NOTEOFF data1:noteNumber data2:velocity at:noteOffPosition];
    return _noteCount;
}

-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat {
    return [self addMIDIEvent:velocity == 0 ? NOTEOFF : NOTEON
                        data1:noteNumber data2:velocity
                           at:beat];
}

-(void)changeNoteAtIndex:(int)index note:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat {
    _events[index].data1 = noteNumber;
    _events[index].data2 = velocity;
    _events[index].beat = beat;
}

- (void)clear {
    _noteCount = 0;
    _playCount = 0;
}

-(void)play {
    [self playAt: nil];
}

-(void)playAt:(AVAudioTime *)audioTime {
    _playCount = 0;
    if (audioTime) {
        AKTimelineStartAtTime(tap.timeline, audioTime.audioTimeStamp);
    } else {
        AKTimelineStart(tap.timeline);
    }
    _isPlaying = true;
}

-(double)beatTime {
    return [self beatTimeAtTime:nil];
}

-(void)setBeatTime:(double)beatTime {
    [self setBeatTime:beatTime atTime:nil];
}

-(void)setBeatTime:(double)beatTime atTime:(AVAudioTime *)audioTime {
    _playCount = 0;

    if (_isPlaying){
        _startOffset = _beatsPerSample * beatTime;
    }
    if (audioTime) {
        AKTimelineSetTimeAtTime(tap.timeline, beatTime / _beatsPerSample, audioTime.audioTimeStamp);
    } else {
        AKTimelineSetTime(tap.timeline, beatTime / _beatsPerSample);
    }
}

-(double)beatTimeAtTime:(AVAudioTime *)audioTime {
    //    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow(); HACK
    return AKTimelineTimeAtTime(tap.timeline, AudioTimeNow()) * _beatsPerSample; // HACK
}

-(void)setTempo:(double)tempo atTime:(AVAudioTime *)audioTime{
    AudioTimeStamp timestamp = [self getValidTimestamp:audioTime];
    [self setTempo:tempo andBeats:_lengthInBeats atTime:timestamp];
}

-(AudioTimeStamp)getValidTimestamp:(AVAudioTime *)audioTime{
    return audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
}

-(void)stop {
    [self resetPlaybackVariables];
    AKTimelineStop(tap.timeline);
}

-(void)stopAfterCurrentNotes {
    _stopAfterCurrentNotes = true;
}

-(void)sendMidiData:(UInt8)status data1:(UInt8)data1 data2:(UInt8)data2 {
    sendMidiData(_audioUnit, _midiPort, _midiEndpoint, status, data1, data2, 0, [self beatTime], 0);
}

- (void)stopAllNotes {
    // Ideally this would work
    //    MusicDeviceMIDIEvent(_sampler.avAudioUnit.audioUnit, 0xB0, 123, 0b0, 0);
    // For now, we'll do it manually
    for(int i=0; i<=127; i++) {
        [self sendMidiData: NOTEOFF data1: i data2: 0];
    }
}

-(void)resetPlaybackVariables {
    _startOffset = INITVALUE;
    _lastStartSample = INITVALUE;
    _playCount = 0;
    _stopAfterCurrentNotes = false;
    _isPlaying = false;
}

-(void)resetTimeLine:(double)lastBeatsPerSample atTime:(AudioTimeStamp)timeStamp {

    Float64 newLoopEnd = _lengthInBeats / _beatsPerSample;

    // Get the current sampleTime in the timeline.
    Float64 lastSampleTime = AKTimelineTimeAtTime(tap.timeline, AudioTimeNow());

    //Manually roll loop if beat change puts us past loop end.
    if (lastSampleTime > newLoopEnd) {
        lastSampleTime -= newLoopEnd;
    }

    // Calculate the beat of sample time at the last tempo.
    double lastBeat = lastSampleTime * lastBeatsPerSample;

    // Calculate the new sample time for last beat.
    double newSampleTime = lastBeat / _beatsPerSample;

    // If timeline is stopped, no need to synchronize with previous timing.
    if (!AKTimelineIsStarted(tap.timeline)) {
        AKTimelineSetTime(tap.timeline, newSampleTime);
        AKTimelineSetLoop(tap.timeline, 0, newLoopEnd);
        return;
    }

    // Timeline is running so we need to get use the reference time to make
    // sure we pick up where we left off.
    AKTimelineSetState(tap.timeline, newSampleTime, 0, newLoopEnd, timeStamp);
}

static AudioTimeStamp AudioTimeNow(void) {
    return (AudioTimeStamp) {
        .mHostTime = mach_absolute_time(),
        .mFlags = kAudioTimeStampHostTimeValid
    };
}
@end
