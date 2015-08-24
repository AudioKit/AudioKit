//
//  AKFFT.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFFT.h"

@implementation AKFFT
{
    AKParameter *aIn;
    AKConstant *iFFTSize;
    AKConstant *iOverlap;
    AKConstant *iWinSize;
    AKConstant *iWinType;
}

+ (AKConstant *)hammingWindow { return akp(0);  }
+ (AKConstant *)hannWindow    { return akp(1);  }

- (instancetype)initWithInput:(AKParameter *)input
                      fftSize:(AKConstant *)fftSize
                      overlap:(AKConstant *)overlap
                   windowType:(AKConstant *)windowType
             windowFilterSize:(AKConstant *)windowSize

{
    self = [super initWithString:[self operationName]];
    if (self) {
        aIn = input;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iWinType = windowType;
        iWinSize = windowSize;
        
        self.state = @"connectable";
        self.dependencies = @[aIn];

    }
    return self;
}

- (NSString *)stringForCSD
{
    return[NSString stringWithFormat:
           @"%@ pvsanal AKAudio(%@), %@, %@, %@, %@",
           self, aIn, iFFTSize, iOverlap, iWinSize, iWinType];
}

@end
