//
//  OCSAudioFromFSignal.m
//  Objective-C Sound
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

@synthesize source=fSrc;

- (id)initWithSource:(OCSFSignal *)source;
{
    self = [super init];
    
    if (self) {
        aRes = [OCSParameter parameterWithString:[self operationName]];
        fSrc = source;
    }
    return self; 
}

// Csound Prototype: ares pvsynth fsrc
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ pvsynth %@", aRes, fSrc];
}

- (NSString *)description {
    return [aRes parameterString];
}

@end
