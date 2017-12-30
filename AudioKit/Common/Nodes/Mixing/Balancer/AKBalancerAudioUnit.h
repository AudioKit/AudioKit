//
//  AKBalancerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import <AudioToolbox/AudioToolbox.h>

@interface AKBalancerAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
@property (readonly) BOOL isPlaying;
@end

