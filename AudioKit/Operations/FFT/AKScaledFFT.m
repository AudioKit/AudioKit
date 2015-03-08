//
//  AKScaledFFT.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKScaledFFT.h"

@implementation AKScaledFFT
{
    AKFSignal *fSigIn;
    AKControl *kScal;
    AKControl *kKeepForm;
    AKControl *kGain;
    AKControl *kCoefs;
}

+ (AKConstant *)noFormantRetainMethod               { return akp(0);  }
+ (AKConstant *)lifteredCepstrumFormantRetainMethod { return akp(1);  }
+ (AKConstant *)trueEnvelopeFormantRetainMethod     { return akp(2);  }

- (instancetype)initWithSignal:(AKFSignal *)input
                frequencyRatio:(AKControl *)frequencyRatio
           formantRetainMethod:(AKControl *)formantRetainMethod
                amplitudeRatio:(AKControl *)amplitudeRatio
          cepstrumCoefficients:(AKControl *)numberOfCepstrumCoefficients;

{
    self = [super initWithString:[self operationName]];
    if (self) {
        if (amplitudeRatio) {
            kGain  = amplitudeRatio;
        } else {
            kGain = akpi(1);
        }
        
        if (numberOfCepstrumCoefficients) {
            kCoefs  = numberOfCepstrumCoefficients;
        } else {
            kCoefs = akpi(80);
        }
        fSigIn = input;
        kScal = frequencyRatio;
        kKeepForm = formantRetainMethod;
        self.state = @"connectable";
        self.dependencies = @[fSigIn, kScal, kGain, kCoefs];
    }
    return self;
}

- (instancetype)initWithSignal:(AKFSignal *)input
                frequencyRatio:(AKControl *)frequencyRatio
{
    return [self initWithSignal:input
                 frequencyRatio:frequencyRatio
            formantRetainMethod:[AKScaledFFT noFormantRetainMethod]
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


