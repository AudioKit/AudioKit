//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKManager.h"

@implementation AKMandolin {
    AKSoundFileTable *_strikeImpulseTable;
}

- (instancetype)initWithBodySize:(AKParameter *)bodySize
                       frequency:(AKParameter *)frequency
                       amplitude:(AKParameter *)amplitude
            pairedStringDetuning:(AKParameter *)pairedStringDetuning
                   pluckPosition:(AKConstant *)pluckPosition
                        loopGain:(AKParameter *)loopGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _bodySize = bodySize;
        _frequency = frequency;
        _amplitude = amplitude;
        _pairedStringDetuning = pairedStringDetuning;
        _pluckPosition = pluckPosition;
        _loopGain = loopGain;
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"]];
        
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _bodySize = akp(0.5);
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _pairedStringDetuning = akp(1);
        _pluckPosition = akp(0.4);
        _loopGain = akp(0.99);
        
        // Constant Values

        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)mandolin
{
    return [[AKMandolin alloc] init];
}

+ (instancetype)presetDefaultMandolin
{
    return [[AKMandolin alloc] init];
}


- (instancetype)initWithPresetDetunedMandolin
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _bodySize = akp(0.7);
        _frequency = akp(440);
        _amplitude = akp(0.5);
        _pairedStringDetuning = akp(0.9);
        _pluckPosition = akp(0.9);
        _loopGain = akp(0.99);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDetunedMandolin
{
    return [[AKMandolin alloc] initWithPresetDetunedMandolin];
}

- (instancetype)initWithPresetSmallMandolin
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _bodySize = akp(0.01);
        _frequency = akp(220);
        _amplitude = akp(0.5);
        _pairedStringDetuning = akp(1);
        _pluckPosition = akp(0.4);
        _loopGain = akp(0.99);
        
        // Constant Values
        
        _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:[AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"]];
        
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallMandolin
{
    return [[AKMandolin alloc] initWithPresetSmallMandolin];
}

- (void)setBodySize:(AKParameter *)bodySize {
    _bodySize = bodySize;
    [self setUpConnections];
}

- (void)setOptionalBodySize:(AKParameter *)bodySize {
    [self setBodySize:bodySize];
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

- (void)setPairedStringDetuning:(AKParameter *)pairedStringDetuning {
    _pairedStringDetuning = pairedStringDetuning;
    [self setUpConnections];
}

- (void)setOptionalPairedStringDetuning:(AKParameter *)pairedStringDetuning {
    [self setPairedStringDetuning:pairedStringDetuning];
}

- (void)setPluckPosition:(AKConstant *)pluckPosition {
    _pluckPosition = pluckPosition;
    [self setUpConnections];
}

- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition {
    [self setPluckPosition:pluckPosition];
}

- (void)setLoopGain:(AKParameter *)loopGain {
    _loopGain = loopGain;
    [self setUpConnections];
}

- (void)setOptionalLoopGain:(AKParameter *)loopGain {
    [self setLoopGain:loopGain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_bodySize, _frequency, _amplitude, _pairedStringDetuning, _pluckPosition, _loopGain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"mandol("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ mandol ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
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

    [inputsString appendFormat:@"%@, ", _pluckPosition];
    
    if ([_pairedStringDetuning class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _pairedStringDetuning];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _pairedStringDetuning];
    }

    if ([_loopGain class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _loopGain];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _loopGain];
    }

    if ([_bodySize class] == [AKControl class]) {
        [inputsString appendFormat:@"2 * (1 - %@), ", _bodySize];
    } else {
        [inputsString appendFormat:@"AKControl(2 * (1 - %@)), ", _bodySize];
    }

    [inputsString appendFormat:@"%@", _strikeImpulseTable];
    return inputsString;
}

@end
