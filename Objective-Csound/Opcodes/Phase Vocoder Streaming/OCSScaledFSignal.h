//
//  OCSScaledFSignal.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSFSignal.h"

/** Scale the frequency components of a pv stream, resulting in pitch shift. 
 Output amplitudes can be optionally modified in order to attempt formant preservation.
 */

typedef enum
{
    kFormantRetainMethodNone=0,
    kFormantRetainMethodLifteredCepstrum=1,
    kFormantRetainMethodTrueEnvelope=2,
} FormantRetainMethodType;

@interface OCSScaledFSignal : OCSOpcode

@property (nonatomic, strong) OCSFSignal *output;

@property (nonatomic, strong) OCSFSignal *input;

@property (nonatomic, strong) OCSControl *frequencyRatio;

@property (nonatomic, strong) OCSControl *formantRetainMethod;

@property (nonatomic, strong) OCSControl *amplitudeRatio;

@property (nonatomic, strong) OCSControl *numberOfCepstrumCoefficients;


- (id)initWithInput:(OCSFSignal *)input
     frequencyRatio:(OCSControl *)frequencyRatio;

- (id)initWithInput:(OCSFSignal *)input
     frequencyRatio:(OCSControl *)frequencyRatio
formantRetainMethod:(FormantRetainMethodType) formantRetainMethod
     amplitudeRatio:(OCSControl *)amplitudeRatio
cepstrumCoefficients:(OCSControl *)numberOfCepstrumCoefficients;


@end
