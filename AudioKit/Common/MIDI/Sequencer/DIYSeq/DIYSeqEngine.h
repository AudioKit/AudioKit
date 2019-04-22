//
//  DIYSeqEngine.h
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#ifndef DIYSeqEngine_h
#define DIYSeqEngine_h
#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKDIYSeqEngine : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) bool loopEnabled;
@property (nonatomic) double tempo;
@property (nonatomic) double lengthInBeats;
@property (nonatomic) double maximumPlayCount;
@property (nonatomic) AKCCallback loopCallback;
@property (nonatomic) double currentPosition;

-(void)setTarget:(AudioUnit)target;
-(void)addMIDIEvent:(uint8_t)status data1:(uint8_t)data1 data2:(uint8_t)data2 beat:(double)beat;
-(void)clear;
-(void)rewind;
-(void)seekTo:(double)seekPosition;

@end

#endif /* DIYSeqEngine_h */
