//
//  AKVCOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vco2:
//  http://www.csounds.com/manual/html/vco2.html
//

#import "AKVCOscillator.h"

@interface AKVCOscillator () {
    AKControl *kcps;
    AKControl *kamp;
    AKConstant *imode;
    AKControl *kpw;
    AKControl *kphs;
    AKConstant *inyx;
}
@end

@implementation AKVCOscillator

- (instancetype)initWithFrequency:(AKControl *)frequency
                        amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kcps = frequency;
        kamp = amplitude;
        imode = akp(0);
        kpw = akp(0);
        kphs = akp(0);
        inyx = akp(0.5);
    }
    return self;
}

- (void)setOptionalWaveformType:(AKConstant *)waveformType {
	imode = waveformType;
}

- (void)setOptionalPulseWidth:(AKControl *)pulseWidth {
	kpw = pulseWidth;
}

- (void)setOptionalPhase:(AKControl *)phase {
	kphs = phase;
}

- (void)setOptionalBandwidth:(AKConstant *)bandwidth {
	inyx = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vco2 %@, %@, %@, %@, %@, %@",
            self, kamp, kcps, imode, kpw, kphs, inyx];
}

@end