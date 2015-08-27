//
//  AKParameterChangeLog.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKParameterChangeLog.h"

@implementation AKParameterChangeLog
{
    NSString *_message;
    AKParameter *_parameter;
}

- (instancetype)initWithMessage:(NSString *)message
                      parameter:(AKParameter *)parameter;
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        _message = message;
        _parameter = parameter;
        self.state = @"connectable";
        self.dependencies = @[parameter];
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"\nprintf \"%@ %%f\", AKControl(%@), AKControl(%@)",
            _message, _parameter, _parameter];
}

- (NSString *)description {
    return @"changeLog";
}
@end
