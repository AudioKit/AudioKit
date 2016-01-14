//
//  AKBandPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandPassButterworthFilterAudioUnit_h
#define AKBandPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBandPassButterworthFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKBandPassButterworthFilterAudioUnit_h */
