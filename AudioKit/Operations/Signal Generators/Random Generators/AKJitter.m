//
//  AKJitter.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "AKJitter.h"
#import "AKManager.h"

@implementation AKJitter

- (instancetype)initWithAmplitude:(AKControl *)amplitude
                 minimumFrequency:(AKControl *)minimumFrequency
                 maximumFrequency:(AKControl *)maximumFrequency
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

- (void)setOptionalAmplitude:(AKControl *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalMinimumFrequency:(AKControl *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
}
- (void)setOptionalMaximumFrequency:(AKControl *)maximumFrequency {
    _maximumFrequency = maximumFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ jitter %@, %@, %@",
            self,
            _amplitude,
            _minimumFrequency,
            _maximumFrequency];
}

@end
