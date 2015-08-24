//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKManager.h"

@implementation AKVibes {
    AKSoundFileTable *_strikeImpulseTable;
}

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                     tremoloShape:(AKTable *)tremoloShape
                 tremoloFrequency:(AKParameter *)tremoloFrequency
                 tremoloAmplitude:(AKParameter *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
        _stickHardness = stickHardness;
        _strikePosition = strikePosition;
        _tremoloShape = tremoloShape;
        _tremoloFrequency = tremoloFrequency;
        _tremoloAmplitude = tremoloAmplitude;
        
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
        _frequency = akp(440);
        _amplitude = akp(0.5);
        _stickHardness = akp(0.5);
        _strikePosition = akp(0.2);
        _tremoloShape = [AKTable standardSineWave];
    
        _tremoloFrequency = akp(0);
        _tremoloAmplitude = akp(0);
        
        // Constant Values
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)vibes
{
    return [[AKVibes alloc] init];
}

+ (instancetype)presetDefaultVibes
{
    return [[AKVibes alloc] init];
}


- (instancetype)initWithPresetTinyVibes
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _amplitude = akp(0.5);
        _stickHardness = akp(0.9);
        _strikePosition = akp(0.1);
        _tremoloShape = [AKTable standardSineWave];
        
        _tremoloFrequency = akp(0);
        _tremoloAmplitude = akp(0);
        
        // Constant Values
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetTinyVibes
{
    return [[AKVibes alloc] initWithPresetTinyVibes];
}

- (instancetype)initWithPresetGentleVibes
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _amplitude = akp(0.5);
        _stickHardness = akp(0);
        _strikePosition = akp(0);
        _tremoloShape = [AKTable standardSineWave];
        
        _tremoloFrequency = akp(0);
        _tremoloAmplitude = akp(0);
        
        // Constant Values
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetGentleVibes
{
    return [[AKVibes alloc] initWithPresetGentleVibes];
}

- (instancetype)initWithPresetRingingVibes;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _amplitude = akp(0.5);
        _stickHardness = akp(0);
        _strikePosition = akp(0.2);
        _tremoloShape = [AKTable standardSineWave];
        
        _tremoloFrequency = akp(1);
        _tremoloAmplitude = akp(1);
        
        // Constant Values
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetRingingVibes;
{
    return [[AKVibes alloc] initWithPresetRingingVibes];
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
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

- (void)setTremoloShape:(AKTable *)tremoloShape {
    _tremoloShape = tremoloShape;
    [self setUpConnections];
}

- (void)setOptionalTremoloShape:(AKTable *)tremoloShape {
    [self setTremoloShape:tremoloShape];
}

- (void)setTremoloFrequency:(AKParameter *)tremoloFrequency {
    _tremoloFrequency = tremoloFrequency;
    [self setUpConnections];
}

- (void)setOptionalTremoloFrequency:(AKParameter *)tremoloFrequency {
    [self setTremoloFrequency:tremoloFrequency];
}

- (void)setTremoloAmplitude:(AKParameter *)tremoloAmplitude {
    _tremoloAmplitude = tremoloAmplitude;
    [self setUpConnections];
}

- (void)setOptionalTremoloAmplitude:(AKParameter *)tremoloAmplitude {
    [self setTremoloAmplitude:tremoloAmplitude];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _amplitude, _stickHardness, _strikePosition, _tremoloFrequency, _tremoloAmplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"vibes("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vibes ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    AKConstant *_maximumDuration = akp(1);        
    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [inputsString appendFormat:@"%@, ", _stickHardness];
    
    [inputsString appendFormat:@"%@, ", _strikePosition];
    
    [inputsString appendFormat:@"%@, ", _strikeImpulseTable];
    
    if ([_tremoloFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _tremoloFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _tremoloFrequency];
    }

    if ([_tremoloAmplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _tremoloAmplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _tremoloAmplitude];
    }

    [inputsString appendFormat:@"%@, ", _tremoloShape];
    
    [inputsString appendFormat:@"%@", _maximumDuration];
    return inputsString;
}

@end
