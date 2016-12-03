//
//  AKResonantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKResonantFilterAudioUnit_h
#define AKResonantFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKResonantFilterAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float bandwidth;
@end

#endif /* AKResonantFilterAudioUnit_h */
