//
//  AKSamplerMetronome.h
//  AudioKit
//
//  Created by David O'Neill on 8/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

/// A Simple Metronome that can be syncronized precisely.
@interface AKSamplerMetronome : AVAudioUnitSampler

/// Tempo in Beats Per Minute
@property double tempo;

/// The number of beats in the loop.
@property int beatCount;

/// The current playback position of the metronome, in beats.
@property double beatTime;

/// Is metronome playing.
@property (readonly) BOOL isPlaying;

///The beat sound url.
@property NSURL * _Nullable sound;

///The down beat sound url.
@property NSURL * _Nullable downBeatSound;

/**
 Initialize with metronome sound and downbeat sound.

 @param soundURL The sound URL
 @param downBeatSoundURL The down beat sound URL, will use soundURL for down beat if nil
 */
-(instancetype _Nonnull )initWithSound:(NSURL * _Nullable)soundURL downBeatSound:(NSURL * _Nullable)downBeatSoundURL NS_DESIGNATED_INITIALIZER;

/**
 Initialize with metronome sound

 @param soundURL The sound URL
 */
-(instancetype _Nonnull )initWithSound:(NSURL * _Nullable)soundURL;

/// Starts playback
-(void)play;

/// Stops playback
-(void)stop;

/**
 Starts playback so that the metronome's resting beatTime will align with audioTime when started.

 If time is in the future, playback will wait to start until that time, if in the past it will start
 immediately, but beatTime will be offset so that it still will align with audioTime.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(void)playAt:(AVAudioTime * _Nullable)audioTime;

/**
 Sets the tempo, if audioTime is not nil and isPlaying, change will take place at audioTime.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(void)setTempo:(double)tempo atTime:(AVAudioTime * _Nullable)audioTime;

/**
 Sets the beatCount, if audioTime is not nil and isPlaying, change will take place at audioTime.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(void)setBeatCount:(int)beatCount atTime:(AVAudioTime * _Nullable)audioTime;

/** Sets the beatTime, if audioTime is not nil and isPlaying, change will take place at audioTime.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(void)setBeatTime:(double)beatTime atTime:(AVAudioTime * _Nullable)audioTime;

/**
 Retrieves the beat time that aligns with audioTime when playing.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(double)beatTimeAtTime:(AVAudioTime * _Nullable)audioTime;

@end
