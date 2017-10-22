//
//  AKSamplerMetronome.m
//  AudioKit
//
//  Created by David O'Neill on 8/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKSamplerMetronome.h"
#import <AudioKit/AudioKit.h>
#import <AudioKit/AudioKit-Swift.h>
#import "AKTimelineTap.h"
#import <mach/mach_time.h>

#define NOTEON 144

@implementation AKSamplerMetronome {
    AKTimelineTap *tap;
    double _beatsPerSample;
    double _sampleRate;
    int _beatCount;
    double _triggers[32];
    BOOL _hasSound;
    BOOL _hasDownBeatSound;
    NSURL *_soundURL;
    NSURL *_downBeatSoundURL;
}

-(instancetype)init {
    return [self initWithSound:nil downBeatSound:nil];
}
-(instancetype)initWithSound:(NSURL *)soundURL downBeatSound:(NSURL *)downBeatSoundURL {
    self = [super init];
    if (self) {
        _sampleRate = [self outputFormatForBus:0].sampleRate;
        _soundURL = soundURL;
        _downBeatSoundURL = downBeatSoundURL;
        
        if (soundURL && ![NSFileManager.defaultManager fileExistsAtPath:soundURL.path]) {
            NSLog(@"File doesn't exist at %@",soundURL.path);
        };
        if (downBeatSoundURL && ![NSFileManager.defaultManager fileExistsAtPath:downBeatSoundURL.path]) {
            NSLog(@"File doesn't exist at %@",downBeatSoundURL.path);
        };
        if (![self setPresetWithSound:soundURL andDownBeatSound:downBeatSoundURL]) {
            [self loadDefaultSounds];
        }
        tap = [[AKTimelineTap alloc]initWithNode:self timelineBlock:[self timlineBlock]];
        tap.preRender = true;
        _beatCount = 4;
        [self setTempo:120];
    }
    return self;
}
-(instancetype)initWithSound:(NSURL *)soundURL{
    return [self initWithSound:soundURL downBeatSound:nil];
}

-(AKTimelineBlock)timlineBlock {
    
    AudioUnit sampler = self.audioUnit;
    double *triggers = _triggers;
    int *triggerCount = &_beatCount;
    BOOL *hasSound = &_hasSound;
    
    return ^(AKTimeline         *timeline,
             AudioTimeStamp     *timeStamp,
             UInt32             offset,
             UInt32             inNumberFrames,
             AudioBufferList    *ioData) {
        
        if (!*hasSound) {
            return;
        }
        
        Float64 startSample = timeStamp->mSampleTime;
        Float64 endSample = startSample + inNumberFrames;
        for (int i = 0; i < *triggerCount; i++) {
            double trigger = triggers[i];
            if(startSample <= trigger && trigger < endSample) {
                MusicDeviceMIDIEvent(sampler,NOTEON, i == 0, 127, trigger - startSample + offset);
            }
        }
    };
}
-(void)setTempo:(double)bpm andbeats:(int)beats atTime:(AudioTimeStamp)timeStamp{
    
    //Store the last beatsPerSample before updating, needed to maintain current beat is running.
    double lastBeatsPerSample = _beatsPerSample;
    
    //Update new tempo, stored as beatsPerSample.
    double beatsPerSecond = bpm / 60.0;
    _beatsPerSample = beatsPerSecond / _sampleRate;
    _beatCount = beats;
    
    Float64 newLoopEnd = _beatCount / _beatsPerSample;
    
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
    
    //This the data will be read from the render thread, so there is a posibility of
    // misfires because we are not writing to it on the main thread.
    for (int i = 0; i < _beatCount; i++) {
        _triggers[i] = (double)i / _beatsPerSample;
    }
    
    // If timeline is stopped, no need to syncronize with previous timing.
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
-(void)setBeatCount:(int)beatCount {
    [self setBeatCount:beatCount atTime:nil];
}
-(int)beatCount {
    return _beatCount;
}
-(void)setTempo:(double)bpm {
    [self setTempo:bpm atTime:nil];
}
-(double)tempo {
    double beatsPerSecond = _beatsPerSample * _sampleRate;
    return beatsPerSecond * 60.0;
}
-(void)play {
    [self playAt:nil];
}
-(void)playAt:(AVAudioTime *)audioTime {
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
    if (audioTime) {
        AKTimelineSetTimeAtTime(tap.timeline, beatTime / _beatsPerSample, audioTime.audioTimeStamp);
    } else {
        AKTimelineSetTime(tap.timeline, beatTime / _beatsPerSample);
    }
}
-(double)beatTimeAtTime:(AVAudioTime *)audioTime {
    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
    return AKTimelineTimeAtTime(tap.timeline, timestamp) * _beatsPerSample;
}

-(void)setTempo:(double)tempo atTime:(AVAudioTime *)audioTime{
    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
    [self setTempo:tempo andbeats:_beatCount atTime:timestamp];
}

-(void)setBeatCount:(int)beatCount atTime:(AVAudioTime *)audioTime{
    if (beatCount > 32) {
        NSLog(@"Beats must be <= 32");
        return;
    }
    AudioTimeStamp timestamp = audioTime ? audioTime.audioTimeStamp : AudioTimeNow();
    [self setTempo:self.tempo andbeats:beatCount atTime:timestamp];
}

-(void)stop {
    AKTimelineStop(tap.timeline);
}
-(void)setSound:(NSURL *)soundURL {
    _soundURL = soundURL;
    if (![NSFileManager.defaultManager fileExistsAtPath:soundURL.path]) {
        NSLog(@"File doesn't exist at %@",soundURL.path);
    }
    [self setPresetWithSound:_soundURL andDownBeatSound:_downBeatSoundURL];
}
-(NSURL *)sound {
    return _soundURL;
}
-(void)setDownBeatSound:(NSURL *)downBeatSoundURL {
    _downBeatSoundURL = downBeatSoundURL;
    if (![NSFileManager.defaultManager fileExistsAtPath:downBeatSoundURL.path]) {
        NSLog(@"File doesn't exist at %@",downBeatSoundURL.path);
    }
    [self setPresetWithSound:_soundURL andDownBeatSound:_downBeatSoundURL];
}
-(NSURL *)downBeatSound {
    return _downBeatSoundURL;
}

// Will use the valid sound for both sounds if one is invalid.
-(BOOL)setPresetWithSound:(NSURL *)soundURL andDownBeatSound:(NSURL *)downBeatSoundURL {
    BOOL soundValid = soundURL && [NSFileManager.defaultManager fileExistsAtPath:soundURL.path];
    BOOL downBeatValid = downBeatSoundURL && [NSFileManager.defaultManager fileExistsAtPath:downBeatSoundURL.path];
    
    _hasSound = soundValid || downBeatValid;
    
    if (!_hasSound) {
        return false;
    }
    
    soundURL = soundValid ? soundURL : downBeatSoundURL;
    downBeatSoundURL = downBeatValid ? downBeatSoundURL : soundURL;
    
    self.preset = [AKPresetManager presetWithFilePaths:@[soundURL.path ,downBeatSoundURL.path] oneShot:true];
    
    return true;
}
static float releasecurve(float scaler) {
    return -1 * scaler * (scaler - 2.f);
}

//Creates a few beeps for sounds in temp, loads them, deletes them.
-(void)loadDefaultSounds {
    float a = 0.004, s = 0.005, r = 0.03;
    float highHz = 2093;
    float lowHz = highHz / 2.0;
    float samplerate = 44100.0;
    int frames = (a + s + r) * samplerate;
    
    AVAudioFormat *format = [[AVAudioFormat alloc]initStandardFormatWithSampleRate:44100 channels:1];
    AVAudioFormat *fileFormat = [[AVAudioFormat alloc]initWithCommonFormat:format.commonFormat sampleRate:format.sampleRate channels:format.channelCount interleaved:true];
    
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:format frameCapacity:frames];
    
    BOOL(^writeToTemp)(NSURL *) = ^BOOL(NSURL *url) {
        NSError *error = nil;
        AVAudioFile *audioFile = [[AVAudioFile alloc]initForWriting:url settings:fileFormat.settings error:&error];
        if (error) {
            NSLog(@"%@",error);
            return false;
        }
        return [audioFile writeFromBuffer:buffer error:&error];
    };
    
    NSURL *highURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"highBeep.caf"]];
    NSURL *lowURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"lowBeep.caf"]];
    
    makeBeep(buffer.mutableAudioBufferList->mBuffers[0].mData, a, s, r, highHz, samplerate, 1);
    buffer.frameLength = frames;
    writeToTemp(highURL);
    
    makeBeep(buffer.mutableAudioBufferList->mBuffers[0].mData, a, s, r, lowHz, samplerate, 0.75);
    buffer.frameLength = frames;
    writeToTemp(lowURL);
    
    [self setPresetWithSound:lowURL andDownBeatSound:highURL];
    [NSFileManager.defaultManager removeItemAtPath:highURL.path error:NULL];
    [NSFileManager.defaultManager removeItemAtPath:lowURL.path error:NULL];
    
}

static int makeBeep(float *buffer, float attack, float sustain, float release, float hz, float samplerate, float volume) {
    
    float totalTime = attack + sustain + release;
    float totalSamples = totalTime * samplerate;
    float samplesPerCyle = samplerate / hz;
    
    for (int i = 0; i < totalSamples; i++) {
        buffer[i] = sinf(M_PI * (i / samplesPerCyle)) * volume;
    }
    int attackSampleCount = attack * samplerate;
    for (int i = 0; i < attackSampleCount; i++) {
        float fadeIn = i / (float)attackSampleCount;
        buffer[i] *= fadeIn;
    }
    int decaySamplesCount = release * samplerate;
    
    int decayStart = totalSamples - decaySamplesCount;
    float *fadeOut = buffer + decayStart;
    for (int i = 0; i < decaySamplesCount; i++) {
        float fader = 1 - releasecurve(i / (float)decaySamplesCount);
        fadeOut[i] *= fader;
    }
    return totalSamples;
}


static AudioTimeStamp AudioTimeNow(void) {
    return (AudioTimeStamp) {
        .mHostTime = mach_absolute_time(),
        .mFlags = kAudioTimeStampHostTimeValid
    };
}
@end
