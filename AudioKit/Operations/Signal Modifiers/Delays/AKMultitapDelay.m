//
//  AKMultitapDelay.m
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//  Customized by Aurelius Prochazka on 12/27/14.
//
//  Implementation of Csound's multitap:
//  http://www.csounds.com/manual/html/multitap.html
//

#import "AKMultitapDelay.h"
#import "AKManager.h"

@implementation AKMultitapDelay
{
    AKParameter * _input;
    AKConstant * _firstEchoTime;
    AKConstant * _firstEchoGain;
    
    NSMutableArray *timesAndGains;
}

- (instancetype)initWithInput:(AKParameter *)input
                firstEchoTime:(AKConstant *)firstEchoTime
                firstEchoGain:(AKConstant *)firstEchoGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _firstEchoTime = firstEchoTime;
        _firstEchoGain = firstEchoGain;
        
        timesAndGains = [[NSMutableArray alloc] init];
        [self addEchoAtTime:firstEchoTime gain:firstEchoGain];
        
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
                 firstEchoTime:(AKConstant *)firstEchoTime
                 firstEchoGain:(AKConstant *)firstEchoGain
{
    return [[AKMultitapDelay alloc] initWithInput:input
                                    firstEchoTime:firstEchoTime
                                    firstEchoGain:firstEchoGain];
}

- (void)addEchoAtTime:(AKConstant *)time gain:(AKConstant *)gain
{
    [timesAndGains addObject:@[time, gain]];
}



- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ multitap ", self];
    
    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }
    
    NSMutableArray *flattenedTimesAndGains = [[NSMutableArray alloc] init];
    for (NSArray *timeAndGain in timesAndGains) {
        [flattenedTimesAndGains addObject:[timeAndGain componentsJoinedByString:@", "]];
    }
    
    [csdString appendFormat:@"%@", [flattenedTimesAndGains componentsJoinedByString:@", "]];
    
    return csdString;
}

@end
