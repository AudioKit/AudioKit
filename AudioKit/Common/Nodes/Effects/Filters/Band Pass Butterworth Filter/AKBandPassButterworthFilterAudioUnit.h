//
//  AKBandPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandPassButterworthFilterAudioUnit_h
#define AKBandPassButterworthFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKBandPassButterworthFilterAudioUnit : AKAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;
@end

#endif /* AKBandPassButterworthFilterAudioUnit_h */
