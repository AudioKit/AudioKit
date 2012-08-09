//
//  OCSScaledFSignal.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSScaledFSignal.h"

@interface OCSScaledFSignal () {
    OCSFSignal *fSig;
    OCSFSignal *fSigIn;
    OCSControl *kScal;
    OCSControl *kKeepForm;
    OCSControl *kGain;
    OCSControl *kCoefs;
}
@end

@implementation OCSScaledFSignal

@synthesize output=fSig;
@synthesize input=fSigIn;
@synthesize frequencyRatio=kScal;
@synthesize formantRetainMethod=kKeepForm;
@synthesize amplitudeRatio=kGain;
@synthesize numberOfCepstrumCoefficients=kCoefs;

- (id)initWithInput:(OCSFSignal *)input
     frequencyRatio:(OCSControl *)frequencyRatio
formantRetainMethod:(FormantRetainMethodType)formantRetainMethod
     amplitudeRatio:(OCSControl *)amplitudeRatio
cepstrumCoefficients:(OCSControl *)numberOfCepstrumCoefficients;

{
    self = [super init];
    
    if (self) {
        
        if (amplitudeRatio) {
            kGain  = amplitudeRatio;
            
        } else {
            kGain = [OCSConstant parameterWithInt:1];
        }
        
        if (numberOfCepstrumCoefficients) {
            kCoefs  = numberOfCepstrumCoefficients;
        } else {
            kCoefs = [OCSConstant parameterWithInt:80];
        }
        fSig = [OCSFSignal parameterWithString:[self opcodeName]];
        fSigIn = input;
        kScal = frequencyRatio;    
        kKeepForm = [OCSConstant parameterWithInt:formantRetainMethod];

    }
    return self;
}

- (id)initWithInput:(OCSFSignal *)input
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
            fSig, fSigIn, kScal, kKeepForm, kGain, kCoefs];
}

- (NSString *)description {
    return [fSig parameterString];
}



@end


