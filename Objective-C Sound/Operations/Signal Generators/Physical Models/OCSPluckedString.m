//
//  OCSPluckedString.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's repluck:
//  http://www.csounds.com/manual/html/repluck.html
//

#import "OCSPluckedString.h"

@interface OCSPluckedString () {
    OCSConstant *icps;
    OCSConstant *iplk;
    OCSControl *kamp;
    OCSControl *kpick;
    OCSControl *krefl;
    OCSAudio *axcite;
}
@end

@implementation OCSPluckedString

- (instancetype)initWithFrequency:(OCSConstant *)frequency
          pluckPosition:(OCSConstant *)pluckPosition
              amplitude:(OCSControl *)amplitude
         samplePosition:(OCSControl *)samplePosition
  reflectionCoefficient:(OCSControl *)reflectionCoefficient
       excitationSignal:(OCSAudio *)excitationSignal
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