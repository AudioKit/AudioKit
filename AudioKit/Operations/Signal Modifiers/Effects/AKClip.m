//
//  AKClip.m
//  AudioKit
//
//  Created by Daniel Clelland on 11/07/15.
//
//  Implementation of Csound's clipper:
//  http://www.csounds.com/manual/html/clip.html
//

#import "AKClip.h"
#import "AKManager.h"

@implementation AKClip
{
    AKParameter * _input;
    AKConstant * _clippingMethod;
    AKConstant * _limit;
    AKConstant * _argument;
}

- (instancetype)initWithInput:(AKParameter *)input
               clippingMethod:(AKConstant *)clippingMethod
                        limit:(AKConstant *)limit
                     argument:(AKConstant *)argument
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _clippingMethod = clippingMethod;
        _limit = limit;
        _argument = argument;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _clippingMethod = akp(AKClipClippingMethodBramDeJong);
        _limit = akp(1.0);
        _argument = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)effectWithInput:(AKParameter *)input
{
    return [[AKClip alloc] initWithInput:input];
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _clippingMethod, _limit, _argument];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"clip("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ clip ", self];
    [csdString appendString:[self inputsString]];
    
    return csdString;
}

- (NSString *)inputsString
{
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }
    
    [inputsString appendFormat:@"%@, ", _clippingMethod];
    [inputsString appendFormat:@"%@, ", _limit];
    [inputsString appendFormat:@"%@", _argument];
    
    return inputsString;
}

@end
