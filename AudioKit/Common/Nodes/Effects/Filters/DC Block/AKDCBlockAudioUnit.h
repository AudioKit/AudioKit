//
//  AKDCBlockAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKDCBlockAudioUnit_h
#define AKDCBlockAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKDCBlockAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKDCBlockAudioUnit_h */
