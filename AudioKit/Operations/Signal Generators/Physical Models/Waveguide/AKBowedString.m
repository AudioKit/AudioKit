//
//  AKBowedString.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wgbow:
//  http://www.csounds.com/manual/html/wgbow.html
//

#import "AKBowedString.h"
#import "AKManager.h"

@implementation AKBowedString

- (instancetype)initWithFrequency:(AKControl *)frequency
                         pressure:(AKControl *)pressure
                         position:(AKControl *)position
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKControl *)vibratoFrequency
                 vibratoAmplitude:(AKControl *)vibratoAmplitude
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
        _vibratoShapeTable = [AKManager sharedAKManager].standardSineTable;
        
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

- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}

- (void)setOptionalPressure:(AKControl *)pressure {
    _pressure = pressure;
}

- (void)setOptionalPosition:(AKControl *)position {
    _position = position;
}

- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable {
    _vibratoShapeTable = vibratoShapeTable;
}

- (void)setOptionalVibratoFrequency:(AKControl *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
}

- (void)setOptionalVibratoAmplitude:(AKControl *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
}

- (void)setOptionalMinimumFrequency:(AKConstant *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
}

- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_amplitude = akp(1);
    return [NSString stringWithFormat:
            @"%@ wgbow %@, %@, %@, %@, %@, %@, %@, %@",
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
