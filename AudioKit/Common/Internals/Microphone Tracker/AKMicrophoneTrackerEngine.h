//
//  AKMicrophoneTrackerEngine.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "EZAudio.h"

@interface AKMicrophoneTrackerEngine : NSObject<EZMicrophoneDelegate>
@property float amplitude;
@property float frequency;

- (void)start;
- (void)stop;
@end
