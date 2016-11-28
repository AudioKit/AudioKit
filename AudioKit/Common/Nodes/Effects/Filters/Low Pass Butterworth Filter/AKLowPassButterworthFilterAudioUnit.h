//
//  AKLowPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowPassButterworthFilterAudioUnit_h
#define AKLowPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKLowPassButterworthFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float cutoffFrequency;

@property double rampTime;

@end

#endif /* AKLowPassButterworthFilterAudioUnit_h */
