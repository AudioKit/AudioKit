//
//  AKConvolution.m
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Customized by Aurelius Prochazka on 12/27/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pconvolve:
//  http://www.csounds.com/manual/html/pconvolve.html
//

#import "AKConvolution.h"
#import "AKManager.h"

@implementation AKConvolution
{
    AKParameter * _input;
    NSString * _impulseResponseFilename;
}

- (instancetype)initWithInput:(AKParameter *)input
      impulseResponseFilename:(NSString *)impulseResponseFilename
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _impulseResponseFilename = impulseResponseFilename;
    }
    return self;
}

+ (instancetype)convolutionWithInput:(AKParameter *)input
             impulseResponseFilename:(NSString *)impulseResponseFilename
{
    return [[AKConvolution alloc] initWithInput:input
      impulseResponseFilename:impulseResponseFilename];
}


- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pconvolve ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    [csdString appendFormat:@"\"%@\"", _impulseResponseFilename];
    
    return csdString;
}

@end
