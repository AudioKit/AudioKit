//
//  OCSAudioFromFSignal.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudioFromFSignal.h"

@interface OCSAudioFromFSignal () {
    OCSParameter *aRes;
    OCSFSignal *fSrc;
}
@end


@implementation OCSAudioFromFSignal

@synthesize output=aRes;
@synthesize source=fSrc;

- (id)initWithSource:(OCSFSignal *)source;
{
    self = [super init];
    
    if (self) {
        aRes = [OCSParameter parameterWithString:[self opcodeName]];
        fSrc = source;
    }
    return self; 
}

// Csound Prototype: ares pvsynth fsrc
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ pvsynth %@", aRes, fSrc];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [aRes parameterString];
}

@end
