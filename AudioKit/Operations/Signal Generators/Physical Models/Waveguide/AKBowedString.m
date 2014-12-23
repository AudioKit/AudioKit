//
//  AKBowedString.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
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
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
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
- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable {
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
    // Constant Values  
    AKConstant *_amplitude = akp(1);        
    return [NSString stringWithFormat:
            @"%@ wgbow AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), %@, %@",
            self,
            _amplitude,
            _frequency,
            _pressure,
            _position,
            _vibratoFrequency,
            _vibratoAmplitude,
            _vibratoShapeTable,
            _minimumFrequency];
}

@end
