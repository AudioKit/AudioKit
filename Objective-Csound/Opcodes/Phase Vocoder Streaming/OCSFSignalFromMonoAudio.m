//
//  OCSFSignalFromMonoAudio.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignalFromMonoAudio.h"

@interface OCSFSignalFromMonoAudio () {
    OCSFSignal *fSig;
    OCSParameter *aIn;
    OCSConstant *iFFTSize;
    OCSConstant *iOverlap;
    OCSConstant *iWinSize;
    OCSConstant *iWinType;
}
@end

@implementation OCSFSignalFromMonoAudio
@synthesize output = fSig;

- (id)initWithInput:(OCSParameter *)monoInput
            fftSize:(OCSConstant *)fftSize
            overlap:(OCSConstant *)overlap
         windowType:(WindowType)windowType
   windowFilterSize:(OCSConstant *)windowSize;

{
    self = [super init];
    if ( self ) {
        fSig = [OCSFSignal parameterWithString:[self opcodeName]];  
        aIn = monoInput;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iWinType = [OCSConstant parameterWithInt:windowType];
        iWinSize = windowSize;
    }
    return self;
}

// Csound Prototype: fsig pvsanal ain, ifftsize, ioverlap, iwinsize, iwintype (, iformat, iinit)
- (NSString *)stringForCSD
{
    return[NSString stringWithFormat:
           @"%@ pvsanal %@, %@, %@, %@, %@",
           fSig, aIn, iFFTSize, iOverlap, iWinSize, iWinType];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [fSig parameterString];
}


@end
