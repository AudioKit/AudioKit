//
//  OCSVCOscillator.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vco2:
//  http://www.csounds.com/manual/html/vco2.html
//

#import "OCSVCOscillator.h"

@interface OCSVCOscillator () {
    OCSControl *kcps;
    OCSControl *kamp;
    OCSConstant *imode;
    OCSControl *kpw;
    OCSControl *kphs;
    OCSConstant *inyx;
}
@end

@implementation OCSVCOscillator

- (instancetype)initWithFrequency:(OCSControl *)frequency
              amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kcps = frequency;
        kamp = amplitude;
        imode = ocsp(0);
        kpw = ocsp(0);
        kphs = ocsp(0);
        inyx = ocsp(0.5);
    }
    return self;
}

- (void)setOptionalWaveformType:(OCSConstant *)waveformType {
	imode = waveformType;
}

- (void)setOptionalPulseWidth:(OCSControl *)pulseWidth {
	kpw = pulseWidth;
}

- (void)setOptionalPhase:(OCSControl *)phase {
	kphs = phase;
}

- (void)setOptionalBandwidth:(OCSConstant *)bandwidth {
	inyx = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vco2 %@, %@, %@, %@, %@, %@",
            self, kamp, kcps, imode, kpw, kphs, inyx];
}

@end