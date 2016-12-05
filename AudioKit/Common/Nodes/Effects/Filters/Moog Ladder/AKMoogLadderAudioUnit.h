//
//  AKMoogLadderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMoogLadderAudioUnit_h
#define AKMoogLadderAudioUnit_h

#import "AKAudioUnit.h"

@interface AKMoogLadderAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@end

#endif /* AKMoogLadderAudioUnit_h */
