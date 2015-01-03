//
//  AKPluckedString.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's repluck:
//  http://www.csounds.com/manual/html/repluck.html
//

#import "AKPluckedString.h"
#import "AKManager.h"

@implementation AKPluckedString
{
    AKParameter * _excitationSignal;
}

- (instancetype)initWithExcitationSignal:(AKParameter *)excitationSignal
                               frequency:(AKConstant *)frequency
                           pluckPosition:(AKConstant *)pluckPosition
                          samplePosition:(AKParameter *)samplePosition
                   reflectionCoefficient:(AKParameter *)reflectionCoefficient
                               amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _excitationSignal = excitationSignal;
        _frequency = frequency;
        _pluckPosition = pluckPosition;
        _samplePosition = samplePosition;
        _reflectionCoefficient = reflectionCoefficient;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)initWithExcitationSignal:(AKParameter *)excitationSignal
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _excitationSignal = excitationSignal;
        // Default Values
        _frequency = akp(440);
        _pluckPosition = akp(0.01);
        _samplePosition = akp(0.1);
        _reflectionCoefficient = akp(0.1);
        _amplitude = akp(1.0);
    }
    return self;
}

+ (instancetype)pluckWithExcitationSignal:(AKParameter *)excitationSignal
{
    return [[AKPluckedString alloc] initWithExcitationSignal:excitationSignal];
}

- (void)setOptionalFrequency:(AKConstant *)frequency {
    _frequency = frequency;
}
- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition {
    _pluckPosition = pluckPosition;
}
- (void)setOptionalSamplePosition:(AKParameter *)samplePosition {
    _samplePosition = samplePosition;
}
- (void)setOptionalReflectionCoefficient:(AKParameter *)reflectionCoefficient {
    _reflectionCoefficient = reflectionCoefficient;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ repluck ", self];

    [csdString appendFormat:@"%@, ", _pluckPosition];
    
    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [csdString appendFormat:@"%@, ", _frequency];
    
    if ([_samplePosition class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _samplePosition];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _samplePosition];
    }

    if ([_reflectionCoefficient class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _reflectionCoefficient];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _reflectionCoefficient];
    }

    if ([_excitationSignal class] == [AKAudio class]) {
        [csdString appendFormat:@"%@", _excitationSignal];
    } else {
        [csdString appendFormat:@"AKAudio(%@)", _excitationSignal];
    }
return csdString;
}

@end
