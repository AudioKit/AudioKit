//
//  AKLog.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKLog.h"

@implementation AKLog
{
    NSString *_message;
    AKParameter *_parameter;
    NSTimeInterval _timeInterval;
}
- (instancetype)initWithMessage:(NSString *)message
                      parameter:(AKParameter *)parameter
                   timeInterval:(NSTimeInterval)timeInterval
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        _message = message;
        _parameter = parameter;
        _timeInterval = timeInterval;
        self.state = @"connectable";
        self.dependencies = @[parameter];
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"\nprintks \"%@ %%f\", %f, AKControl(%@)\n",
            _message, _timeInterval, _parameter];
}

- (NSString *)description {
    return @"log";
}
@end
