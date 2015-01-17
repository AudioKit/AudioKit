//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKManager.h"

@implementation AKVibes

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                tremoloShapeTable:(AKFunctionTable *)tremoloShapeTable
                 tremoloFrequency:(AKParameter *)tremoloFrequency
                 tremoloAmplitude:(AKParameter *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
        _stickHardness = stickHardness;
        _strikePosition = strikePosition;
        _tremoloShapeTable = tremoloShapeTable;
        _tremoloFrequency = tremoloFrequency;
        _tremoloAmplitude = tremoloAmplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _amplitude = akp(1.0);
        _stickHardness = akp(0.5);
        _strikePosition = akp(0.2);
        _tremoloShapeTable = [AKManager standardSineWave];
    
        _tremoloFrequency = akp(0);
        _tremoloAmplitude = akp(0);
    }
    return self;
}

+ (instancetype)vibes
{
    return [[AKVibes alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalStickHardness:(AKConstant *)stickHardness {
    _stickHardness = stickHardness;
}
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition {
    _strikePosition = strikePosition;
}
- (void)setOptionalTremoloShapeTable:(AKFunctionTable *)tremoloShapeTable {
    _tremoloShapeTable = tremoloShapeTable;
}
- (void)setOptionalTremoloFrequency:(AKParameter *)tremoloFrequency {
    _tremoloFrequency = tremoloFrequency;
}
- (void)setOptionalTremoloAmplitude:(AKParameter *)tremoloAmplitude {
    _tremoloAmplitude = tremoloAmplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    NSString *file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
    if (!file) {
        file = @"CsoundLib64.framework/Sounds/marmstk1.wav";
    }

    AKSoundFile *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFile alloc] initWithFilename:file];
    [[[[AKManager sharedManager] orchestra] functionTables] addObject:_strikeImpulseTable];
            
    AKConstant *_maximumDuration = akp(1);        
    [csdString appendFormat:@"%@ vibes ", self];

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

    [csdString appendFormat:@"%@, ", _stickHardness];
    
    [csdString appendFormat:@"%@, ", _strikePosition];
    
    [csdString appendFormat:@"%@, ", _strikeImpulseTable];
    
    if ([_tremoloFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _tremoloFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _tremoloFrequency];
    }

    if ([_tremoloAmplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _tremoloAmplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _tremoloAmplitude];
    }

    [csdString appendFormat:@"%@, ", _tremoloShapeTable];
    
    [csdString appendFormat:@"%@", _maximumDuration];
    return csdString;
}

@end
