//
//  AKStringResonatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKStringResonatorAudioUnit_h
#define AKStringResonatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKStringResonatorAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKStringResonatorAudioUnit_h */
