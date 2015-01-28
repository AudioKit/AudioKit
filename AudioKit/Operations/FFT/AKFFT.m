//
//  AKFSignalFromMonoAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignalFromMonoAudio.h"

@implementation AKFSignalFromMonoAudio
{
    AKParameter *aIn;
    AKConstant *iFFTSize;
    AKConstant *iOverlap;
    AKConstant *iWinSize;
    AKConstant *iWinType;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                            fftSize:(AKConstant *)fftSize
                            overlap:(AKConstant *)overlap
                         windowType:(AKFSignalFromMonoAudioWindowType)windowType
                   windowFilterSize:(AKConstant *)windowSize

{
    self = [super initWithString:[self operationName]];
    if ( self ) {
        aIn = audioSource;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iWinType = akpi(windowType);
        iWinSize = windowSize;
    }
    return self;
}

// Csound Prototype: fsig pvsanal ain, ifftsize, ioverlap, iwinsize, iwintype (, iformat, iinit)
- (NSString *)stringForCSD
{
    return[NSString stringWithFormat:
           @"%@ pvsanal %@, %@, %@, %@, %@",
           self, aIn, iFFTSize, iOverlap, iWinSize, iWinType];
}

@end
