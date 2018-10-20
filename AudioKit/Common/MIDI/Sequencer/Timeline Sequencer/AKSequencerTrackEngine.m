//
//  AKSequencerInternalTrack
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

struct MIDIEvent {
    double sampleTime;
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
};

struct MIDINote {
    struct MIDIEvent noteOn;
    struct MIDIEvent noteOff;
};


@implementation AKSequencerTrackEngine {
    AKTimelineTap *tap;
    struct MIDIEvent _events[256];
    int _noteCount;
    double _lastTriggerTime;
    double _beatsPerSample;
    double _sampleRate;
    double _lengthInBeats;
    int _playCount;
    int _maximumPlays;
    BOOL _hasSound;
    AudioUnit _audioUnit;
    Float64 _startOffset;
}

@synthesize maximumPlayCount = _maximumPlays;
@synthesize trackIndex = _trackIndex;
@synthesize timeMultiplier = _timeMultiplier;
@synthesize noteOffset = _noteOffset;
@synthesize lengthInBeats = _lengthInBeats;

-(instancetype)init {
    return [self initWithNode:nil];
}

- (instancetype)initWithNode:(AKNode *)node{
    return [self initWithNode:node index:arc4random_uniform(333)];
}

- (instancetype)initWithNode:(AKNode *)node index:(int)index{
    self = [super init];
    if (self) {
        _sampleRate = 44100;
        _audioUnit = [[node avAudioUnit] audioUnit];
        _playCount = 0;
        _maximumPlays = 0;
        _noteCount = 0;
        _trackIndex = index;
        _timeMultiplier = 1;
        _noteOffset = 0;
        [self resetStartOffset];
        tap = [[AKTimelineTap alloc]initWithNode:node.avAudioNode timelineBlock:[self timelineBlock]];
        tap.preRender = true;
        _lengthInBeats = 4;
        [self setTempo:120];
    }
    return self;
}

-(void)setLengthInBeats:(double)lengthInBeats {
    _lengthInBeats = lengthInBeats;

    //Store the last beatsPerSample before updating, needed to maintain current beat is running.
    double lastBeatsPerSample = _beatsPerSample;

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

    // This data will be read from the render thread, so there is a posibility of
    // misfires because we are not writing to it on the main thread.
    for (int i = 0; i < _noteCount; i++) {
        _events[i].sampleTime = (double)_events[i].beat / _beatsPerSample;
    }

    // If timeline is stopped, no need to synchronize with previous timing.
    if (!AKTimelineIsStarted(tap.timeline)) {
        AKTimelineSetTime(tap.timeline, newSampleTime);
        AKTimelineSetLoop(tap.timeline, 0, newLoopEnd);
        return;
    }

    // Timeline is running so we need to get use the reference time to make
    // sure we pick up where we left off.
    AKTimelineSetState(tap.timeline, newSampleTime, 0, newLoopEnd, AudioTimeNow());
}

-(AKTimelineBlock)timelineBlock {
    AudioUnit instrument = _audioUnit;
    struct MIDIEvent *events = _events;
    int *playCount = &_playCount;
    int *maximumPlays = &_maximumPlays;
    int *noteCount = &_noteCount;
    int *trackIndex = &_trackIndex;
    int *noteOffset = &_noteOffset;
    double *timeMultiplier = &_timeMultiplier;
    double *lastTriggerTime = &_lastTriggerTime;
    __block Float64 *startOffset = &_startOffset;

    return ^(AKTimeline         *timeline,
             AudioTimeStamp     *timeStamp,
             UInt32             offset,
             UInt32             inNumberFrames,
             AudioBufferList    *ioData) {

        if (*startOffset < 0) {
            *startOffset = timeStamp->mSampleTime;
        }

        Float64 startSample = timeStamp->mSampleTime - *startOffset;
        Float64 endSample = startSample + inNumberFrames;

        if (startSample > *lastTriggerTime) { //Hack
            *playCount += 1;
        }

        if (*maximumPlays != 0 && *playCount >= *maximumPlays) {
            [self stop];
            return;
        }

        for (int i = 0; i < *noteCount; i++) {
            double triggerTime = _events[i].sampleTime * *timeMultiplier;

            if(((startSample <= triggerTime && triggerTime < endSample)))
            {
//                //printf("note @ %llu on track %i \n", mach_absolute_time(), *trackIndex);
//                MusicDeviceMIDIEvent(instrument,
//                                     events[i].velocity == 0 ? NOTEOFF : NOTEON,
//                                     notes[i].noteNumber + *noteOffset,
//                                     notes[i].velocity,
//                                     triggerTime - startSample + offset);
                MusicDeviceMIDIEvent(instrument,
                                     events[i].status, events[i].data1, events[i].data2,
                                     triggerTime - startSample + offset);
            }
        }
    };
}

-(void)setTempo:(double)bpm andBeats:(int)beats atTime:(AudioTimeStamp)timeStamp{

    //Store the last beatsPerSample before updating, needed to maintain current beat is running.
    double lastBeatsPerSample = _beatsPerSample;

    //Update new tempo, stored as beatsPerSample.
    double beatsPerSecond = bpm / 60.0;
    _beatsPerSample = beatsPerSecond / _sampleRate;
    _lengthInBeats = beats;

    Float64 newLoopEnd = _lengthInBeats / _beatsPerSample;

    // Get the current sampleTime in the timeline.
    Float64 lastSampleTime = AKTimelineTimeAtTime(tap.timeline, timeStamp);

    //Manually roll loop if beat change puts us past loop end.
    if (lastSampleTime > newLoopEnd) {
        lastSampleTime -= newLoopEnd;
    }

    // Calculate the beat of sample time at the last tempo.
    double lastBeat = lastSampleTime * lastBeatsPerSample;

    // Calculate the new sample time for last beat.
    double newSampleTime = lastBeat / _beatsPerSample;

    // This data will be read from the render thread, so there is a posibility of
    // misfires because we are not writing to it on the main thread.
    for (int i = 0; i < _noteCount; i++) {
        _events[i].sampleTime = (double)_events[i].beat / _beatsPerSample;
    }

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

-(BOOL)isPlaying {
    return AKTimelineIsStarted(tap.timeline);
}

-(void)setBeatCount:(double)length {
    [self setBeatCount:length atTime:nil];
}

-(double)length {
    return _lengthInBeats;
}

-(void)setTempo:(double)bpm {
    [self setTempo:bpm atTime:nil];
}

-(double)tempo {
    double beatsPerSecond = _beatsPerSample * _sampleRate;
    return beatsPerSecond * 60.0;
}


-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat duration:(double)duration {
    [self addNote:noteNumber velocity:velocity at:beat];
    [self addNote:noteNumber velocity:0 at:beat + duration];
    return _noteCount;
}

-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat {
    _events[_noteCount].status = velocity == 0 ? NOTEOFF : NOTEON;
    _events[_noteCount].data1 = noteNumber;
    _events[_noteCount].data2 = velocity;
    _events[_noteCount].beat = beat;
    _events[_noteCount].sampleTime = beat / _beatsPerSample;

    _noteCount += 1;

    _lastTriggerTime = 0.0;
    for (int i = 0; i < _noteCount; i++) {
        if (_events[i].sampleTime > _lastTriggerTime) _lastTriggerTime = _events[i].sampleTime;
    }
    return _noteCount - 1;
}

-(void)changeNoteAtIndex:(int)index note:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat {
    _events[index].data1 = noteNumber;
    _events[index].data2 = velocity;
    _events[index].beat = beat;
    _events[index].sampleTime = beat / _beatsPerSample;
}

- (void)clear {
    _noteCount = 0;
    _playCount = 0;
}

-(void)play {
    _playCount = 0;
    [self playAt: nil];
}

-(void)playAt:(AVAudioTime *)audioTime {
    _playCount = 0;
    if (audioTime) {
        AKTimelineStartAtTime(tap.timeline, audioTime.audioTimeStamp);
    } else {
        AKTimelineStart(tap.timeline);
    }
}

-(double)beatTime {
    return [self beatTimeAtTime:nil];
}

-(void)setBeatTime:(double)beatTime {
    [self setBeatTime:beatTime atTime:nil];
}

-(void)setBeatTime:(double)beatTime atTime:(AVAudioTime *)audioTime {
    _playCount = 0;

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
    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
    [self setTempo:tempo andBeats:_lengthInBeats atTime:timestamp];
}

-(void)setBeatCount:(double)length atTime:(AVAudioTime *)audioTime{
    if (length > 32) {
        NSLog(@"Beats must be <= 32");
        return;
    }
    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
    [self setTempo:self.tempo andBeats:length atTime:timestamp];
}

-(void)stop {
    [self resetStartOffset];
    [self stopAllNotes];
    _playCount = 0;
    AKTimelineStop(tap.timeline);
}

- (void)stopAllNotes {
    // Ideally this would work
    //    MusicDeviceMIDIEvent(_sampler.avAudioUnit.audioUnit, 0xB0, 123, 0b0, 0);
    // For now, we'll do it manually
    for(int i=0; i<=127; i++) {
        MusicDeviceMIDIEvent(_audioUnit, NOTEOFF, i, 0, 0);
    }
}

-(void)resetStartOffset {
    _startOffset = -1.f;
}

static AudioTimeStamp AudioTimeNow(void) {
    return (AudioTimeStamp) {
        .mHostTime = mach_absolute_time(),
        .mFlags = kAudioTimeStampHostTimeValid
    };
}
@end
