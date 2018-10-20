//
//  AKSequencerTrackEngine.h
//  AudioKit
//
//  Created by Aurelius Prochazka, Jeff Cooper remix 20181018 revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class AKNode;

/// A Sequencer that can be synchronized precisely.
@interface AKSequencerTrackEngine : NSObject

/// Tempo in Beats Per Minute
@property double tempo;

/// The length of the sequence.
@property double lengthInBeats;

/// The current playback position of the sequence, in beats.
@property double beatTime;

@property int maximumPlayCount;
@property int trackIndex;
@property double timeMultiplier;
@property int noteOffset;

/// Is metronome playing.
@property (readonly) BOOL isPlaying;

///The beat soundfont url.
@property NSURL * _Nullable sound;
@property NSURL * _Nullable melodicSound;

-(instancetype _Nonnull )initWithNode:(AKNode * _Nullable)node;
-(instancetype _Nonnull )initWithNode:(AKNode * _Nullable)node index:(int)index;

/// Starts playback
-(void)play;

/// Stops playback
-(void)stop;

/// Clear notes;
-(void)clear;

/// Add a note to be sequenced
-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat;
-(int)addNote:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat duration:(double)duration;
-(void)changeNoteAtIndex:(int)index note:(uint8_t)noteNumber velocity:(uint8_t)velocity at:(double)beat;

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
-(void)setBeatCount:(double)beatCount atTime:(AVAudioTime * _Nullable)audioTime;

/** Sets the beatTime, if audioTime is not nil and isPlaying, change will take place at audioTime.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(void)setBeatTime:(double)beatTime atTime:(AVAudioTime * _Nullable)audioTime;

/**
 Retrieves the beat time that aligns with audioTime when playing.

 @param audioTime A time relative the audio render context, host time will be ignnored unless sampleTime is invalid.
 */
-(double)beatTimeAtTime:(AVAudioTime * _Nullable)audioTime;
-(void)stopAllNotes;

@end
