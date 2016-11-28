//
//  AKHighPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKHighPassButterworthFilterAudioUnit_h
#define AKHighPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKHighPassButterworthFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float cutoffFrequency;

@property double rampTime;

@end

#endif /* AKHighPassButterworthFilterAudioUnit_h */
