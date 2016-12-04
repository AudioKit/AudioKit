//
//  AKAutoWahAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAutoWahAudioUnit_h
#define AKAutoWahAudioUnit_h

#import "AKAudioUnit.h"

@interface AKAutoWahAudioUnit : AKAudioUnit
@property (nonatomic) float wah;
@property (nonatomic) float mix;
@property (nonatomic) float amplitude;
@end

#endif /* AKAutoWahAudioUnit_h */
