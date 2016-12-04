//
//  AKBitCrusherAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBitCrusherAudioUnit_h
#define AKBitCrusherAudioUnit_h

#import "AKAudioUnit.h"

@interface AKBitCrusherAudioUnit : AKAudioUnit
@property (nonatomic) float bitDepth;
@property (nonatomic) float sampleRate;
@end

#endif /* AKBitCrusherAudioUnit_h */
