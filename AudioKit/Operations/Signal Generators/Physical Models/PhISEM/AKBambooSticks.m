//
//  AKBambooSticks.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/15/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's bamboo:
//  http://www.csounds.com/manual/html/bamboo.html
//

#import "AKBambooSticks.h"
#import "AKManager.h"

@implementation AKBambooSticks

- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
      secondResonantFrequency:(AKConstant *)secondResonantFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
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
        _count = akp(2);    
        _mainResonantFrequency = akp(2800);    
        _firstResonantFrequency = akp(2240);    
        _secondResonantFrequency = akp(3360);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKBambooSticks alloc] init];
}

- (void)setOptionalCount:(AKConstant *)count {
    _count = count;
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
    AKConstant *_dampingFactor = akp(0);        
    return [NSString stringWithFormat:
            @"%@ bamboo %@, %@, %@, %@, %@, %@, %@, %@",
            self,
            _amplitude,
            _maximumDuration,
            _count,
            _dampingFactor,
            _energyReturn,
            _mainResonantFrequency,
            _firstResonantFrequency,
            _secondResonantFrequency];
}

@end
