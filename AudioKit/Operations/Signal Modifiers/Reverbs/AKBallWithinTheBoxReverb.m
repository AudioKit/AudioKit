//
//  AKBallWithinTheBoxReverb.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's babo:
//  http://www.csounds.com/manual/html/babo.html
//

#import "AKBallWithinTheBoxReverb.h"

@implementation AKBallWithinTheBoxReverb
{
    AKConstant *irx;
    AKConstant *iry;
    AKConstant *irz;
    AKControl *ksrcx;
    AKControl *ksrcy;
    AKControl *ksrcz;
    AKAudio *asig;
    AKConstant *idiff;
}

- (instancetype)initWithLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge
                        lengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge
                        lengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge
                                xLocation:(AKControl *)xLocation
                                yLocation:(AKControl *)yLocation
                                zLocation:(AKControl *)zLocation
                              audioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        irx = lengthOfXAxisEdge;
        iry = lengthOfYAxisEdge;
        irz = lengthOfZAxisEdge;
        ksrcx = xLocation;
        ksrcy = yLocation;
        ksrcz = zLocation;
        asig = audioSource;
        idiff = akp(0);
    }
    return self;
}

- (void)setOptionalDiffusion:(AKConstant *)diffusion {
	idiff = diffusion;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ babo %@, %@, %@, %@, %@, %@, %@, %@",
            self, asig, ksrcx, ksrcy, ksrcz, irx, iry, irz, idiff];
}

@end