//
//  OCSFSignalFromMonoAudio.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignalFromMonoAudio.h"

@interface OCSFSignalFromMonoAudio () {
    OCSParameter *aIn;
    OCSConstant *iFFTSize;
    OCSConstant *iOverlap;
    OCSConstant *iWinSize;
    OCSConstant *iWinType;
}
@end

@implementation OCSFSignalFromMonoAudio

- (id)initWithAudioSource:(OCSAudio *)audioSource
                  fftSize:(OCSConstant *)fftSize
                  overlap:(OCSConstant *)overlap
               windowType:(WindowType)windowType
         windowFilterSize:(OCSConstant *)windowSize

{
    self = [super initWithString:[self operationName]];
    if ( self ) {
        aIn = audioSource;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iWinType = ocspi(windowType);
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
