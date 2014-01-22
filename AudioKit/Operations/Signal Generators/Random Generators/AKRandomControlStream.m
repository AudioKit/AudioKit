//
//  AKRandomControlStream.m
//  WindSounds
//
//  Created by Adam Boulanger on 9/30/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "AKRandomControlStream.h"

@implementation AKRandomControlStream
{
    AKControl *max;
    AKControl *freq;
    AKConstant *iSeed;
    AKConstant *size;
    AKConstant *off;
}

- (instancetype)initWithMaximum:(AKControl *)maximum
                      frequency:(AKControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        max = maximum;
        freq = frequency;
        iSeed = akp(0.5);
        size = akpi(0);
        off = akpi(0);
    }
    return self;
}

- (void)setOptionalSeed:(AKConstant *)seed
{
    iSeed = seed;
}

- (void)setOptionalOffset:(AKConstant *)offset
{
    off = offset;
}

- (void)useSystemSeed
{
    iSeed = akp(2);
}

- (void)useThirtyOneBitOutput
{
    off = akp(1);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"%@ randi %@, %@, %@, %@, %@", self, max, freq, iSeed, size, off];
}


@end
