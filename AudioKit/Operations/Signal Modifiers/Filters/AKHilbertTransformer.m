//
//  AKHilbertTransformer.m
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's hilbert:
//  http://www.csounds.com/manual/html/hilbert.html
//

#import "AKHilbertTransformer.h"
#import "AKManager.h"

@implementation AKHilbertTransformer
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKHilbertTransformer alloc] initWithInput:input];
}

- (AKAudio *)realPart {
    return self.leftOutput;
}
- (AKAudio *)imaginaryPart {
    return self.rightOutput;
}
- (AKAudio *)sineOutput {
    return self.leftOutput;
}
- (AKAudio *)cosineOutput{
    return self.rightOutput;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ hilbert ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@)", _input];
    }
return csdString;
}

@end
