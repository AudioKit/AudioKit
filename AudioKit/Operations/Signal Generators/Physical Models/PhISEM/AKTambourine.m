//
//  AKTambourine.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/11/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tambourine:
//  http://www.csounds.com/manual/html/tambourine.html
//

#import "AKTambourine.h"
#import "AKManager.h"

@implementation AKTambourine

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        _mainResonantFrequency = mainResonantFrequency;
        _firstResonantFrequency = firstResonantFrequency;
        _secondResonantFrequency = secondResonantFrequency;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
        // Default Values
        _intensity = akp(1000);
        _dampingFactor = akp(0.1);
        _mainResonantFrequency = akp(2300);
        _firstResonantFrequency = akp(5600);
        _secondResonantFrequency = akp(8100);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKTambourine alloc] init];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    _intensity = intensity;
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}

- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency {
    _mainResonantFrequency = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
    _firstResonantFrequency = firstResonantFrequency;
}

- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency {
    _secondResonantFrequency = secondResonantFrequency;
}
- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_amplitude = akp(1);
    AKConstant *_energyReturn = akp(0);
    AKConstant *_maximumDuration = akp(1);
    return [NSString stringWithFormat:
            @"%@ tambourine %@, %@, %@, (1 - %@) * 0.7, %@, %@, %@, %@",
            self,
            _amplitude,
            _maximumDuration,
            _intensity,
            _dampingFactor,
            _energyReturn,
            _mainResonantFrequency,
            _firstResonantFrequency,
            _secondResonantFrequency];
}


@end
