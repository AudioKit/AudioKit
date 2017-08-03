//
//  AKMicrophoneTrackerEngine.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/9/17.
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
