//
//  AKBandRejectButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandRejectButterworthFilterAudioUnit_h
#define AKBandRejectButterworthFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKBandRejectButterworthFilterAudioUnit : AKAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;
@end

#endif /* AKBandRejectButterworthFilterAudioUnit_h */
