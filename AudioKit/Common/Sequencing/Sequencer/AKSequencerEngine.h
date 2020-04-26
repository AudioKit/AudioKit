// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKSequencerEngine : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) bool loopEnabled;
@property (nonatomic) double tempo;
@property (readonly) double currentPosition;
@property (nonatomic) double length;
@property (nonatomic) double maximumPlayCount;
@property (nonatomic) AKCCallback loopCallback;

-(void)setTarget:(AudioUnit)target;
-(void)addMIDIEvent:(uint8_t)status
              data1:(uint8_t)data1
              data2:(uint8_t)data2
               beat:(double)beat;
-(void)addMIDINote:(uint8_t)number
          velocity:(uint8_t)velocity
              beat:(double)beat
          duration:(double)duration;
-(void)removeEvent:(double)beat;
-(void)removeNote:(double)beat;
-(void)clear;
-(void)rewind;
-(void)seekTo:(double)seekPosition;
-(void)stopPlayingNotes;

@end
