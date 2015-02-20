//
//  AKConvolution.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to simplify the interface.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pconvolve:
//  http://www.csounds.com/manual/html/pconvolve.html
//

#import "AKConvolution.h"
#import "AKManager.h"

@implementation AKConvolution
{
    AKParameter *_input;
    NSString *_impulseResponseFilename;
}

- (instancetype)initWithInput:(AKParameter *)input
      impulseResponseFilename:(NSString *)impulseResponseFilename
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _impulseResponseFilename = impulseResponseFilename;
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)convolutionWithInput:(AKParameter *)input
             impulseResponseFilename:(NSString *)impulseResponseFilename
{
    return [[AKConvolution alloc] initWithInput:input
                        impulseResponseFilename:impulseResponseFilename];
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pconvolve("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pconvolve ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    [inputsString appendFormat:@"\"%@\"", _impulseResponseFilename];

    
    return inputsString;
}

@end
