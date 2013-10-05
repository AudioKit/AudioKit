//
//  OCSRandomControlStream.m
//  WindSounds
//
//  Created by Adam Boulanger on 9/30/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSRandomControlStream.h"

@implementation OCSRandomControlStream
{
    OCSControl *max;
    OCSControl *freq;
    OCSConstant *iSeed;
    OCSConstant *size;
    OCSConstant *off;
}

- (id)initWithMaximum:(OCSControl *)maximum
            frequency:(OCSControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        max = maximum;
        freq = frequency;
        iSeed = ocsp(0.5);
        size = ocspi(0);
        off = ocspi(0);
    }
    return self;
}

- (void)setOptionalSeed:(OCSConstant *)seed
{
    iSeed = seed;
}

- (void)setOptionalOffset:(OCSConstant *)offset
{
    off = offset;
}

- (void)useSystemSeed
{
    iSeed = ocsp(2);
}

- (void)useThirtyOneBitOutput
{
    off = ocsp(1);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"%@ randi %@, %@, %@, %@, %@", self, max, freq, iSeed, size, off];
}


@end
