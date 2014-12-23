//
//  AKLowFrequencyOscillatingControl.m
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillatingControl.h"
#import "AKManager.h"

@implementation AKLowFrequencyOscillatingControl

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
        _type = AKLowFrequencyOscillatorTypeSine;    
        _amplitude = akp(1);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKLowFrequencyOscillatingControl alloc] init];
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
