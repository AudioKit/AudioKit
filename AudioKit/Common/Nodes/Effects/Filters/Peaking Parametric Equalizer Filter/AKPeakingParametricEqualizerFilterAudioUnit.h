//
//  AKPeakingParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPeakingParametricEqualizerFilterAudioUnit_h
#define AKPeakingParametricEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPeakingParametricEqualizerFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKPeakingParametricEqualizerFilterAudioUnit_h */
