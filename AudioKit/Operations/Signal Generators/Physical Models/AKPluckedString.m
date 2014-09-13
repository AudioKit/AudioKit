//
//  AKPluckedString.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's repluck:
//  http://www.csounds.com/manual/html/repluck.html
//

#import "AKPluckedString.h"

@implementation AKPluckedString
{
    AKConstant *icps;
    AKConstant *iplk;
    AKControl *kamp;
    AKControl *kpick;
    AKControl *krefl;
    AKAudio *axcite;
}

- (instancetype)initWithFrequency:(AKConstant *)frequency
                    pluckPosition:(AKConstant *)pluckPosition
                        amplitude:(AKControl *)amplitude
                   samplePosition:(AKControl *)samplePosition
            reflectionCoefficient:(AKControl *)reflectionCoefficient
                 excitationSignal:(AKAudio *)excitationSignal
{
    self = [super initWithString:[self operationName]];
    if (self) {
        icps = frequency;
        iplk = pluckPosition;
        kamp = amplitude;
        kpick = samplePosition;
        krefl = reflectionCoefficient;
        axcite = excitationSignal;
        
        
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ repluck %@, %@, %@, %@, %@, %@",
            self, iplk, kamp, icps, kpick, krefl, axcite];
}

@end