//
//  AKJitter.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "AKJitter.h"
#import "AKManager.h"

@implementation AKJitter

- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                 minimumFrequency:(AKParameter *)minimumFrequency
                 maximumFrequency:(AKParameter *)maximumFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _amplitude = amplitude;
        _minimumFrequency = minimumFrequency;
        _maximumFrequency = maximumFrequency;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _amplitude = akp(1);    
        _minimumFrequency = akp(0);    
        _maximumFrequency = akp(60);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKJitter alloc] init];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalMinimumFrequency:(AKParameter *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
}
- (void)setOptionalMaximumFrequency:(AKParameter *)maximumFrequency {
    _maximumFrequency = maximumFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ jitter AKControl(%@), AKControl(%@), AKControl(%@)",
            self,
            _amplitude,
            _minimumFrequency,
            _maximumFrequency];
}

@end
