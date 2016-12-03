//
//  AKLowPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowPassButterworthFilterAudioUnit_h
#define AKLowPassButterworthFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKLowPassButterworthFilterAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@end

#endif /* AKLowPassButterworthFilterAudioUnit_h */
