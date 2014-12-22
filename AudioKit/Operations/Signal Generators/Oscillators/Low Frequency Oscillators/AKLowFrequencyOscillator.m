//
//  AKLowFrequencyOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillator.h"
#import "AKManager.h"

@implementation AKLowFrequencyOscillator

- (instancetype)initWithFrequency:(AKControl *)frequency
                             type:(AKLowFrequencyOscillatorType)type
                        amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _type = type;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(110);    
        _type = 0;    
        _amplitude = akp(1);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKLowFrequencyOscillator alloc] init];
}

- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}
- (void)setOptionalType:(AKLowFrequencyOscillatorType)type {
    _type = type;
}
- (void)setOptionalAmplitude:(AKControl *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lfo %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            akpi(_type)];
}

@end
