//
//  AKPluckedString.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's repluck:
//  http://www.csounds.com/manual/html/repluck.html
//

#import "AKPluckedString.h"
#import "AKManager.h"

@implementation AKPluckedString
{
    AKAudio *_excitationSignal;
}

- (instancetype)initWithExcitationSignal:(AKAudio *)excitationSignal
                               frequency:(AKConstant *)frequency
                           pluckPosition:(AKConstant *)pluckPosition
                          samplePosition:(AKControl *)samplePosition
                   reflectionCoefficient:(AKControl *)reflectionCoefficient
                               amplitude:(AKControl *)amplitude
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

- (instancetype)initWithExcitationSignal:(AKAudio *)excitationSignal
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

+ (instancetype)audioWithExcitationSignal:(AKAudio *)excitationSignal
{
    return [[AKPluckedString alloc] initWithExcitationSignal:excitationSignal];
}

- (void)setOptionalFrequency:(AKConstant *)frequency {
    _frequency = frequency;
}

- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition {
    _pluckPosition = pluckPosition;
}

- (void)setOptionalSamplePosition:(AKControl *)samplePosition {
    _samplePosition = samplePosition;
}

- (void)setOptionalReflectionCoefficient:(AKControl *)reflectionCoefficient {
    _reflectionCoefficient = reflectionCoefficient;
}

- (void)setOptionalAmplitude:(AKControl *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ repluck %@, %@, %@, %@, %@, %@",
            self,
            _pluckPosition,
            _amplitude,
            _frequency,
            _samplePosition,
            _reflectionCoefficient,
            _excitationSignal];
}


@end
