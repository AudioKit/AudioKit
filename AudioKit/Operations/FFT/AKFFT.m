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

- (instancetype)initWithInput:(AKParameter *)audioSource
                      fftSize:(AKConstant *)fftSize
                      overlap:(AKConstant *)overlap
                   windowType:(AKFFTWindowType)windowType
             windowFilterSize:(AKConstant *)windowSize

{
    self = [super initWithString:[self operationName]];
    if (self) {
        aIn = audioSource;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iWinType = akpi(windowType);
        iWinSize = windowSize;
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
