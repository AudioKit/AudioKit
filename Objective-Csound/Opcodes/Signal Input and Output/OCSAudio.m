//
//  OCSAudio.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"

@interface OCSAudio () {
    OCSParameter *inputLeft;
    OCSParameter *inputRight;
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
        inputLeft  = leftInput;
        inputRight = rightInput;
    }
    return self; 
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@, %@",inputLeft, inputRight];
}

@end
