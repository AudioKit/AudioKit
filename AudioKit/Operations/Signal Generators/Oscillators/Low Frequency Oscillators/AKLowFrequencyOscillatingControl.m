//
//  AKLowFrequencyOscillatingControl.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillatingControl.h"
#import "AKManager.h"

@implementation AKLowFrequencyOscillatingControl
{
    AKLowFrequencyOscillatorType _type;
}

- (instancetype)initWithType:(AKLowFrequencyOscillatorType)type
                   frequency:(AKParameter *)frequency
                   amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _type = type;
        _frequency = frequency;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)initWithType:(AKLowFrequencyOscillatorType)type
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _type = type;
        // Default Values
        _frequency = akp(110);    
        _amplitude = akp(1);    
    }
    return self;
}

+ (instancetype)controlWithType:(AKLowFrequencyOscillatorType)type
{
    return [[AKLowFrequencyOscillatingControl alloc] initWithType:type];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lfo AKControl(%@), AKControl(%@), %@",
            self,
            _amplitude,
            _frequency,
            akpi(_type)];
}

@end
