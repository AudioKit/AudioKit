//
//  AKMarimba.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's marimba:
//  http://www.csounds.com/manual/html/marimba.html
//

#import "AKMarimba.h"
#import "AKManager.h"

@implementation AKMarimba {
    AKSoundFileTable *_strikeImpulseTable;
}

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKConstant *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                     vibratoShape:(AKTable *)vibratoShape
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
        _vibratoShape = vibratoShape;
        _vibratoFrequency = vibratoFrequency;
        _vibratoAmplitude = vibratoAmplitude;
        _doubleStrikePercentage = doubleStrikePercentage;
        _tripleStrikePercentage = tripleStrikePercentage;
        
        // Constant Values
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _stickHardness = akp(0);
        _strikePosition = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
    
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _doubleStrikePercentage = akp(40);
        _tripleStrikePercentage = akp(20);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)marimba
{
    return [[AKMarimba alloc] init];
}

+ (instancetype)presetDefaultMarimba
{
    return [[AKMarimba alloc] init];
}

- (instancetype)initWithPresetGentleMarimba
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _stickHardness = akp(0.1);
        _strikePosition = akp(0.9);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _doubleStrikePercentage = akp(40);
        _tripleStrikePercentage = akp(20);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetGentleMarimba
{
    return [[AKMarimba alloc] initWithPresetGentleMarimba];
}

- (instancetype)initWithPresetDryMutedMarimba
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _stickHardness = akp(0.1);
        _strikePosition = akp(12);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0.1);
        _doubleStrikePercentage = akp(40);
        _tripleStrikePercentage = akp(20);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDryMutedMarimba
{
    return [[AKMarimba alloc] initWithPresetDryMutedMarimba];
}

- (instancetype)initWithPresetLooseMarimba
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _stickHardness = akp(1);
        _strikePosition = akp(1);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(12);
        _vibratoAmplitude = akp(0.9);
        _doubleStrikePercentage = akp(10);
        _tripleStrikePercentage = akp(10);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetLooseMarimba
{
    return [[AKMarimba alloc] initWithPresetLooseMarimba];
}


- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setAmplitude:(AKConstant *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKConstant *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setStickHardness:(AKConstant *)stickHardness {
    _stickHardness = stickHardness;
    [self setUpConnections];
}

- (void)setOptionalStickHardness:(AKConstant *)stickHardness {
    [self setStickHardness:stickHardness];
}

- (void)setStrikePosition:(AKConstant *)strikePosition {
    _strikePosition = strikePosition;
    [self setUpConnections];
}

- (void)setOptionalStrikePosition:(AKConstant *)strikePosition {
    [self setStrikePosition:strikePosition];
}

- (void)setVibratoShape:(AKTable *)vibratoShape {
    _vibratoShape = vibratoShape;
    [self setUpConnections];
}

- (void)setOptionalVibratoShape:(AKTable *)vibratoShape {
    [self setVibratoShape:vibratoShape];
}

- (void)setVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
    [self setUpConnections];
}

- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    [self setVibratoFrequency:vibratoFrequency];
}

- (void)setVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
    [self setUpConnections];
}

- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    [self setVibratoAmplitude:vibratoAmplitude];
}

- (void)setDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage {
    _doubleStrikePercentage = doubleStrikePercentage;
    [self setUpConnections];
}

- (void)setOptionalDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage {
    [self setDoubleStrikePercentage:doubleStrikePercentage];
}

- (void)setTripleStrikePercentage:(AKConstant *)tripleStrikePercentage {
    _tripleStrikePercentage = tripleStrikePercentage;
    [self setUpConnections];
}

- (void)setOptionalTripleStrikePercentage:(AKConstant *)tripleStrikePercentage {
    [self setTripleStrikePercentage:tripleStrikePercentage];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _amplitude, _stickHardness, _strikePosition, _vibratoFrequency, _vibratoAmplitude, _doubleStrikePercentage, _tripleStrikePercentage];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"marimba("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ marimba ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    AKConstant *_maximumDuration = akp(1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    if ([_frequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [inputsString appendFormat:@"(4.8-2*%@), ", _stickHardness];
    
    [inputsString appendFormat:@"%@, ", _strikePosition];
    
    [inputsString appendFormat:@"%@, ", _strikeImpulseTable];
    
    if ([_vibratoFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _vibratoFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _vibratoFrequency];
    }

    if ([_vibratoAmplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _vibratoAmplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _vibratoAmplitude];
    }

    [inputsString appendFormat:@"%@, ", _vibratoShape];
    
    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _doubleStrikePercentage];
    
    [inputsString appendFormat:@"%@", _tripleStrikePercentage];
    return inputsString;
}

@end
