//
//  AKMix.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's ntrpol:
//  http://www.csounds.com/manual/html/ntrpol.html
//

#import "AKMix.h"

@implementation AKMix
{
    AKParameter *in1;
    AKParameter *in2;
    AKConstant *min;
    AKConstant *max;
    AKParameter *current;
}

- (instancetype)initWithInput1:(AKParameter *)input1
                        input2:(AKParameter *)input2
                        balance:(AKParameter *)balancePoint;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = akp(0.0);
        max = akp(1.0);
        current = balancePoint;
        in1 = input1;
        in2 = input2;
        self.state = @"connectable";
        self.dependencies = @[in1, in2, current, min, max];
    }
    return self;
}

- (instancetype)initMonoAudioFromStereoInput:(AKStereoAudio *)stereoInput
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = akp(0.0);
        max = akp(1.0);
        current = akp(0.5);
        in1 = stereoInput.leftOutput;
        in2 = stereoInput.rightOutput;
        self.state = @"connectable";
        self.dependencies = @[stereoInput];
    }
    return self;
}


- (void)setMinimumBalancePoint:(AKConstant *)minimumBalancePoint {
    min = minimumBalancePoint;
}
- (void)setMaximumBalancePoint:(AKConstant *)maximumBalancePoint {
    max = maximumBalancePoint;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"ntrpol("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ ntrpol ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    
    if ([in1 class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", in1];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", in1];
    }

    if ([in2 class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", in2];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", in2];
    }
    
    if ([current class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", current];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", current];
    }
    
    [inputsString appendFormat:@"%@, ", min];
    
    [inputsString appendFormat:@"%@", max];
    return inputsString;
}


@end
