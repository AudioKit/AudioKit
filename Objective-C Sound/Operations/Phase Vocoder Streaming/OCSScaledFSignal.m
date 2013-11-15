//
//  OCSScaledFSignal.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSScaledFSignal.h"

@interface OCSScaledFSignal () {
    OCSFSignal *fSigIn;
    OCSControl *kScal;
    OCSControl *kKeepForm;
    OCSControl *kGain;
    OCSControl *kCoefs;
}
@end

@implementation OCSScaledFSignal

- (instancetype)initWithInput:(OCSFSignal *)input
     frequencyRatio:(OCSControl *)frequencyRatio
formantRetainMethod:(FormantRetainMethodType)formantRetainMethod
     amplitudeRatio:(OCSControl *)amplitudeRatio
cepstrumCoefficients:(OCSControl *)numberOfCepstrumCoefficients;

{
    self = [super initWithString:[self operationName]];
    if (self) {
        if (amplitudeRatio) {
            kGain  = amplitudeRatio;
        } else {
            kGain = ocspi(1);
        }
        
        if (numberOfCepstrumCoefficients) {
            kCoefs  = numberOfCepstrumCoefficients;
        } else {
            kCoefs = ocspi(80);
        }
        fSigIn = input;
        kScal = frequencyRatio;    
        kKeepForm = [OCSConstant constantWithInt:formantRetainMethod];

    }
    return self;
}

- (instancetype)initWithInput:(OCSFSignal *)input
     frequencyRatio:(OCSControl *)frequencyRatio
{
    return [self initWithInput:input 
                frequencyRatio:frequencyRatio
           formantRetainMethod:kFormantRetainMethodNone
                amplitudeRatio:nil
          cepstrumCoefficients:nil];
}


// Csound Prototype: fsig pvscale fsigin, kscal[, kkeepform, kgain, kcoefs]
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:
            @"%@ pvscale %@, %@, %@, %@, %@", 
            self, fSigIn, kScal, kKeepForm, kGain, kCoefs];
}

@end


