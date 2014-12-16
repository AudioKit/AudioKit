//
//  AKSleighbells.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/15/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's sleighbells:
//  http://www.csounds.com/manual/html/sleighbells.html
//

#import "AKSleighbells.h"
#import "AKManager.h"

@implementation AKSleighbells

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
        _intensity = akp(32);    
        _dampingFactor = akp(0.2);    
        _mainResonantFrequency = akp(2500);    
        _firstResonantFrequency = akp(5300);    
        _secondResonantFrequency = akp(6500);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKSleighbells alloc] init];
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
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    return [NSString stringWithFormat:
            @"%@ sleighbells %@, %@, %@, (1 - %@) * 0.25, %@, %@, %@, %@",
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
