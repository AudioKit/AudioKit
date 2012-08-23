//
//  OCSFSignalMix.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignalMix.h"

@interface OCSFSignalMix () {
    OCSFSignal *fSig;
    OCSFSignal *fSigIn1;
    OCSFSignal *fSigIn2;
}
@end

@implementation OCSFSignalMix

@synthesize output=fSig;
@synthesize input1=fSigIn1;
@synthesize input2=fSigIn2;


- (id)initWithInput1:(OCSFSignal *)input1
input2:(OCSFSignal *)input2;
{
    self = [super init];
    
    if (self) {
        fSig = [OCSFSignal parameterWithString:[self operationName]];
        fSigIn1 = input1;
        fSigIn2 = input2;
    }
    return self; 
}

// Csound Prototype: fsig pvsmix fsigin1, fsigin2
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ pvsmix %@, %@", fSig, fSigIn1, fSigIn2];
}

- (NSString *)description {
    return [fSig parameterString];
}

@end
