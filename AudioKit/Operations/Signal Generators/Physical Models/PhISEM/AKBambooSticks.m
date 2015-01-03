//
//  AKBambooSticks.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
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
                    amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
        _mainResonantFrequency = mainResonantFrequency;
        _firstResonantFrequency = firstResonantFrequency;
        _secondResonantFrequency = secondResonantFrequency;
        _amplitude = amplitude;
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
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)sticks
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
- (void)setOptionalAmplitude:(AKConstant *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_dampingFactor = akp(0);        
    [csdString appendFormat:@"%@ bamboo ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    [csdString appendFormat:@"%@, ", _maximumDuration];
    
    [csdString appendFormat:@"%@, ", _count];
    
    [csdString appendFormat:@"%@, ", _dampingFactor];
    
    [csdString appendFormat:@"%@, ", _energyReturn];
    
    [csdString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [csdString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [csdString appendFormat:@"%@", _secondResonantFrequency];
    return csdString;
}

@end
