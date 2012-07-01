//
//  OCSAudio.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"

@interface OCSAudio () {
    OCSParam *inputLeft;
    OCSParam *inputRight;
}
@end

@implementation OCSAudio

- (id)initWithMonoInput:(OCSParam *)monoSignal
{
    return [self initWithLeftInput:monoSignal rightInput:monoSignal];
}

- (id)initWithLeftInput:(OCSParam *)leftInput rightInput:(OCSParam *)rightInput
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
