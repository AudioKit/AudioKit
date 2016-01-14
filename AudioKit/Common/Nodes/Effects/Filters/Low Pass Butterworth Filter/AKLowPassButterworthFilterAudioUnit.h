//
//  AKLowPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowPassButterworthFilterAudioUnit_h
#define AKLowPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKLowPassButterworthFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKLowPassButterworthFilterAudioUnit_h */
