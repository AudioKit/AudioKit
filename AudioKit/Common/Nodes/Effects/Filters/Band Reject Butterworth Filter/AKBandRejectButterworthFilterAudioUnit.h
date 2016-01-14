//
//  AKBandRejectButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandRejectButterworthFilterAudioUnit_h
#define AKBandRejectButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBandRejectButterworthFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKBandRejectButterworthFilterAudioUnit_h */
