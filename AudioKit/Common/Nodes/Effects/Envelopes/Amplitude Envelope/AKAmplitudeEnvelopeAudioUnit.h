//
//  AKAmplitudeEnvelopeAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAmplitudeEnvelopeAudioUnit_h
#define AKAmplitudeEnvelopeAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKAmplitudeEnvelopeAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKAmplitudeEnvelopeAudioUnit_h */
