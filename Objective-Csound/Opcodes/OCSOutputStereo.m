//
//  OCSOutputStereo.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOutputStereo.h"

@interface OCSOutputStereo () {
    OCSParam *inputLeft;
    OCSParam *inputRight;
}
@end

@implementation OCSOutputStereo

- (id)initWithMonoInput:(OCSParam *)monoSignal
{
    return [self initWithLeftInput:monoSignal RightInput:monoSignal];
}

- (id)initWithLeftInput:(OCSParam *)leftInput
             RightInput:(OCSParam *)rightInput
{
    self = [super init];
    if (self) {
        inputLeft  = leftInput;
        inputRight = rightInput;
    }
    return self; 
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@, %@\n",inputLeft, inputRight];
}

@end
