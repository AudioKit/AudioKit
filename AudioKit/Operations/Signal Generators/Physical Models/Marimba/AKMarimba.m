//
//  AKMarimba.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Customized by Aurelius Prochazka on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's marimba:
//  http://www.csounds.com/manual/html/marimba.html
//

#import "AKMarimba.h"
#import "AKManager.h"
#import "AKSoundFileTable.h"

@implementation AKMarimba

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKParameter *)vibratoFrequency
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
           doubleStrikePercentage:(AKConstant *)doubleStrikePercentage
           tripleStrikePercentage:(AKConstant *)tripleStrikePercentage
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
        _stickHardness = stickHardness;
        _strikePosition = strikePosition;
        _vibratoShapeTable = vibratoShapeTable;
        _vibratoFrequency = vibratoFrequency;
        _vibratoAmplitude = vibratoAmplitude;
        _doubleStrikePercentage = doubleStrikePercentage;
        _tripleStrikePercentage = tripleStrikePercentage;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);    
        _amplitude = akp(1);    
        _stickHardness = akp(0.5);    
        _strikePosition = akp(0.5);    
        _vibratoShapeTable = [AKManager standardSineTable];
        
        _vibratoFrequency = akp(0);    
        _vibratoAmplitude = akp(0);    
        _doubleStrikePercentage = akp(40);    
        _tripleStrikePercentage = akp(20);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKMarimba alloc] init];
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
- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable {
    _vibratoShapeTable = vibratoShapeTable;
}
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
}
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
}
- (void)setOptionalDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage {
    _doubleStrikePercentage = doubleStrikePercentage;
}
- (void)setOptionalTripleStrikePercentage:(AKConstant *)tripleStrikePercentage {
    _tripleStrikePercentage = tripleStrikePercentage;
}

- (NSString *)stringForCSD {
    // Constant Values  
    AKConstant *_maximumDuration = akp(1);
    
    
    NSString *file;
    if ([[[AKManager sharedManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Operations/Signal Generators/Physical Models/Marimba/marmstk1.wav"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
    }
    NSLog(@"file %@", file);
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ marimba AKControl(%@), AKControl(%@), %@, %@, %@, AKControl(%@), AKControl(%@), %@, %@, %@, %@",
            [_strikeImpulseTable stringForCSD],
            self,
            _amplitude,
            _frequency,
            _stickHardness,
            _strikePosition,
            _strikeImpulseTable,
            _vibratoFrequency,
            _vibratoAmplitude,
            _vibratoShapeTable,
            _maximumDuration,
            _doubleStrikePercentage,
            _tripleStrikePercentage];
}

@end
