//
//  AKDroplet.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's dripwater:
//  http://www.csounds.com/manual/html/dripwater.html
//

#import "AKDroplet.h"
#import "AKManager.h"

@implementation AKDroplet

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
                     energyReturn:(AKConstant *)energyReturn
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        _energyReturn = energyReturn;
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
        _intensity = akp(10);    
        _dampingFactor = akp(0.1);    
        _energyReturn = akp(0.5);    
        _mainResonantFrequency = akp(450);    
        _firstResonantFrequency = akp(600);    
        _secondResonantFrequency = akp(750);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKDroplet alloc] init];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    _intensity = intensity;
}
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}
- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn {
    _energyReturn = energyReturn;
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
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_amplitude = akp(1);        
    return [NSString stringWithFormat:
            @"%@ dripwater AKControl(%@), %@, %@, (1 - %@), %@, %@, %@, %@",
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
