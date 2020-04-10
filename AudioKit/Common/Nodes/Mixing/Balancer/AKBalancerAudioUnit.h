// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import <AudioToolbox/AudioToolbox.h>

@interface AKBalancerAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
@property (readonly) BOOL isPlaying;
@end

