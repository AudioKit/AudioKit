// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "EZAudio.h"

@interface AKMicrophoneTrackerEngine : NSObject<EZMicrophoneDelegate>

- (instancetype)initWithHopSize:(UInt32)hopSize peakCount:(UInt32)peakCount;

@property float amplitude;
@property float frequency;

- (void)start;
- (void)stop;
@end
