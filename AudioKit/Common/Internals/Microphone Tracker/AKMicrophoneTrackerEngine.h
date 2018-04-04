//
//  AKMicrophoneTrackerEngine.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "EZAudio.h"

@interface AKMicrophoneTrackerEngine : NSObject<EZMicrophoneDelegate>

- (instancetype)initWithHopSize:(UInt32)hopSize peakCount:(UInt32)peakCount;

@property float amplitude;
@property float frequency;

- (void)start;
- (void)stop;
@end
