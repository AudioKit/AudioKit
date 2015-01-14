//
//  AKFlute.m
//  AudioKit
//
//  Auto-generated on 1/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wgflute:
//  http://www.csounds.com/manual/html/wgflute.html
//

#import "AKFlute.h"
#import "AKManager.h"

@implementation AKFlute

- (instancetype)initWithFrequency:(AKParameter *)frequency
                       attackTime:(AKConstant *)attackTime
                      releaseTime:(AKConstant *)releaseTime
                   airJetPressure:(AKParameter *)airJetPressure
                            jetrf:(AKConstant *)jetrf
                            endrf:(AKConstant *)endrf
                   noiseAmplitude:(AKParameter *)noiseAmplitude
                        amplitude:(AKParameter *)amplitude
                     vibratoShape:(AKFunctionTable *)vibratoShape
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 vibratoFrequency:(AKParameter *)vibratoFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _attackTime = attackTime;
        _releaseTime = releaseTime;
        _airJetPressure = airJetPressure;
        _jetrf = jetrf;
        _endrf = endrf;
        _noiseAmplitude = noiseAmplitude;
        _amplitude = amplitude;
        _vibratoShape = vibratoShape;
        _vibratoAmplitude = vibratoAmplitude;
        _vibratoFrequency = vibratoFrequency;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _attackTime = akp(0.1);
        _releaseTime = akp(0.1);
        _airJetPressure = akp(0.2);
        _jetrf = akp(0.5);
        _endrf = akp(0.5);
        _noiseAmplitude = akp(0.15);
        _amplitude = akp(0.5);
        _vibratoShape = [AKManager standardSineWave];
    
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
    }
    return self;
}

+ (instancetype)flute
{
    return [[AKFlute alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAttackTime:(AKConstant *)attackTime {
    _attackTime = attackTime;
}
- (void)setOptionalReleaseTime:(AKConstant *)releaseTime {
    _releaseTime = releaseTime;
}
- (void)setOptionalAirJetPressure:(AKParameter *)airJetPressure {
    _airJetPressure = airJetPressure;
}
- (void)setOptionalJetrf:(AKConstant *)jetrf {
    _jetrf = jetrf;
}
- (void)setOptionalEndrf:(AKConstant *)endrf {
    _endrf = endrf;
}
- (void)setOptionalNoiseAmplitude:(AKParameter *)noiseAmplitude {
    _noiseAmplitude = noiseAmplitude;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalVibratoShape:(AKFunctionTable *)vibratoShape {
    _vibratoShape = vibratoShape;
}
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
}
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_initializationParameter = akp(0);        
    [csdString appendFormat:@"%@ wgflute ", self];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    if ([_airJetPressure class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _airJetPressure];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _airJetPressure];
    }

    [csdString appendFormat:@"%@, ", _attackTime];
    
    [csdString appendFormat:@"%@, ", _releaseTime];
    
    if ([_noiseAmplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _noiseAmplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _noiseAmplitude];
    }

    if ([_vibratoFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _vibratoFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _vibratoFrequency];
    }

    if ([_vibratoAmplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _vibratoAmplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _vibratoAmplitude];
    }

    [csdString appendFormat:@"%@, ", _vibratoShape];
    
    [csdString appendFormat:@"%@, ", _initializationParameter];
    
    [csdString appendFormat:@"%@, ", _jetrf];
    
    [csdString appendFormat:@"%@", _endrf];
    return csdString;
}

@end
