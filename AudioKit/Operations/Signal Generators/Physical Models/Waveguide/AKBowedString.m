//
//  AKBowedString.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wgbow:
//  http://www.csounds.com/manual/html/wgbow.html
//

#import "AKBowedString.h"
#import "AKManager.h"

@implementation AKBowedString

- (instancetype)initWithFrequency:(AKParameter *)frequency
                         pressure:(AKParameter *)pressure
                         position:(AKParameter *)position
                vibratoShapeTable:(AKFunctionTable *)vibratoShapeTable
                 vibratoFrequency:(AKParameter *)vibratoFrequency
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 minimumFrequency:(AKConstant *)minimumFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _pressure = pressure;
        _position = position;
        _vibratoShapeTable = vibratoShapeTable;
        _vibratoFrequency = vibratoFrequency;
        _vibratoAmplitude = vibratoAmplitude;
        _minimumFrequency = minimumFrequency;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(110);
        _pressure = akp(3);
        _position = akp(0.127236);
        _vibratoShapeTable = [AKManager standardSineTable];
    
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKBowedString alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalPressure:(AKParameter *)pressure {
    _pressure = pressure;
}
- (void)setOptionalPosition:(AKParameter *)position {
    _position = position;
}
- (void)setOptionalVibratoShapeTable:(AKFunctionTable *)vibratoShapeTable {
    _vibratoShapeTable = vibratoShapeTable;
}
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
}
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
}
- (void)setOptionalMinimumFrequency:(AKConstant *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_amplitude = akp(1);        
    [csdString appendFormat:@"%@ wgbow ", self];

    if ([_amplitude isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    if ([_pressure isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _pressure];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _pressure];
    }

    if ([_position isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _position];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _position];
    }

    if ([_vibratoFrequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _vibratoFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _vibratoFrequency];
    }

    if ([_vibratoAmplitude isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _vibratoAmplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _vibratoAmplitude];
    }

    [csdString appendFormat:@"%@, ", _vibratoShapeTable];
    
    [csdString appendFormat:@"%@", _minimumFrequency];
    return csdString;
}

@end
