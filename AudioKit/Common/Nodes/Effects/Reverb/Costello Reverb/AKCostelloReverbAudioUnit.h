//
//  AKCostelloReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCostelloReverbAudioUnit_h
#define AKCostelloReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKCostelloReverbAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKCostelloReverbAudioUnit_h */
