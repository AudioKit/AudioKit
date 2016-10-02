//
//  AKBalancerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBalancerAudioUnit_h
#define AKBalancerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBalancerAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKBalancerAudioUnit_h */
