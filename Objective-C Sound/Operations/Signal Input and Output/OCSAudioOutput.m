//
//  OCSAudioOutput.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudioOutput.h"

@interface OCSAudioOutput () {
    OCSParameter *aSig1;
    OCSParameter *aSig2;
}
@end

@implementation OCSAudioOutput

- (id)initWithMonoInput:(OCSAudio *)monoSignal
{
    return [self initWithLeftInput:monoSignal rightInput:monoSignal];
}

- (id)initWithLeftInput:(OCSAudio *)leftInput rightInput:(OCSAudio *)rightInput
{
    self = [super init];
    if (self) {
        aSig1  = leftInput;
        aSig2 = rightInput;
    }
    return self; 
}

// Csound prototype: outs asig1, asig2
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@, %@", aSig1, aSig2];
}

@end
