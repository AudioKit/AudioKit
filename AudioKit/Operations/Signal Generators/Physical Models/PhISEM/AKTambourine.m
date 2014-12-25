//
//  AKTambourine.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
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
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tambourine ", self];

    if ([_amplitude isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [csdString appendFormat:@"%@, ", _maximumDuration];
    
    [csdString appendFormat:@"%@, ", _intensity];
    
    [csdString appendFormat:@"(1 - %@) * 0.7, ", _dampingFactor];
    
    [csdString appendFormat:@"%@, ", _energyReturn];
    
    [csdString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [csdString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [csdString appendFormat:@"%@", _secondResonantFrequency];
    return csdString;
}

@end
