//
//  OCSAudio.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"

@interface OCSAudio () {
    OCSParameter *aSig1;
    OCSParameter *aSig2;
}
@end

@implementation OCSAudio

- (id)initWithMonoInput:(OCSParameter *)monoSignal
{
    return [self initWithLeftInput:monoSignal rightInput:monoSignal];
}

- (id)initWithLeftInput:(OCSParameter *)leftInput rightInput:(OCSParameter *)rightInput
{
    self = [super init];
    if (self) {
        aSig1  = leftInput;
        aSig2 = rightInput;
    }
    return self; 
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@, %@", aSig1, aSig2];
}

@end
