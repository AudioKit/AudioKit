//
//  AKPluckedString.m
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's repluck:
//  http://www.csounds.com/manual/html/repluck.html
//

#import "AKPluckedString.h"
#import "AKManager.h"
#import "AKMonoSoundFileLooper.h"

@implementation AKPluckedString {
    AKMonoSoundFileLooper *_excitationSignal;
}

- (instancetype)initWithFrequency:(AKConstant *)frequency
                    pluckPosition:(AKConstant *)pluckPosition
                   samplePosition:(AKParameter *)samplePosition
            reflectionCoefficient:(AKParameter *)reflectionCoefficient
                        amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _pluckPosition = pluckPosition;
        _samplePosition = samplePosition;
        _reflectionCoefficient = reflectionCoefficient;
        _amplitude = amplitude;

        // Constant Values
        NSString *file = [AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"];
        AKSoundFileTable *strikeImpulseTable;
        strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
        _excitationSignal = [[AKMonoSoundFileLooper alloc] initWithSoundFile:strikeImpulseTable];
        _excitationSignal.loopMode = [AKMonoSoundFileLooper loopPlaysOnce];

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
        _pluckPosition = akp(0.01);
        _samplePosition = akp(0.1);
        _reflectionCoefficient = akp(1);
        _amplitude = akp(0.5);

        // Constant Values
        NSString *file = [AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"];
        AKSoundFileTable *strikeImpulseTable;
        strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
        _excitationSignal = [[AKMonoSoundFileLooper alloc] initWithSoundFile:strikeImpulseTable];
        _excitationSignal.loopMode = [AKMonoSoundFileLooper loopPlaysOnce];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)pluck
{
    return [[AKPluckedString alloc] init];
}

+ (instancetype)presetDefaultPluckedString
{
    return [[AKPluckedString alloc] init];
}

- (instancetype)initWithPresetDecayingPluckedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _pluckPosition = akp(0.01);
        _samplePosition = akp(0.1);
        _reflectionCoefficient = akp(0.5);
        _amplitude = akp(0.5);
        
        // Constant Values
        NSString *file = [AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"];
        AKSoundFileTable *strikeImpulseTable;
        strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
        _excitationSignal = [[AKMonoSoundFileLooper alloc] initWithSoundFile:strikeImpulseTable];
        _excitationSignal.loopMode = [AKMonoSoundFileLooper loopPlaysOnce];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDecayingPluckedString
{
    return [[AKPluckedString alloc] initWithPresetDecayingPluckedString];
}

- (instancetype)initWithPresetRoundedPluckedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _pluckPosition = akp(0.5);
        _samplePosition = akp(0.5);
        _reflectionCoefficient = akp(0.5);
        _amplitude = akp(0.5);
        
        // Constant Values
        NSString *file = [AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"];
        AKSoundFileTable *strikeImpulseTable;
        strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
        _excitationSignal = [[AKMonoSoundFileLooper alloc] initWithSoundFile:strikeImpulseTable];
        _excitationSignal.loopMode = [AKMonoSoundFileLooper loopPlaysOnce];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetRoundedPluckedString
{
    return [[AKPluckedString alloc] initWithPresetRoundedPluckedString];
}

- (instancetype)initWithPresetSnappyPluckedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _pluckPosition = akp(0.5);
        _samplePosition = akp(0.05);
        _reflectionCoefficient = akp(0.5);
        _amplitude = akp(0.5);
        
        // Constant Values
        NSString *file = [AKManager pathToSoundFile:@"marmstk1" ofType:@"wav"];
        AKSoundFileTable *strikeImpulseTable;
        strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
        _excitationSignal = [[AKMonoSoundFileLooper alloc] initWithSoundFile:strikeImpulseTable];
        _excitationSignal.loopMode = [AKMonoSoundFileLooper loopPlaysOnce];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSnappyPluckedString
{
    return [[AKPluckedString alloc] initWithPresetSnappyPluckedString];
}

- (void)setFrequency:(AKConstant *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKConstant *)frequency {
    [self setFrequency:frequency];
}

- (void)setPluckPosition:(AKConstant *)pluckPosition {
    _pluckPosition = pluckPosition;
    [self setUpConnections];
}

- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition {
    [self setPluckPosition:pluckPosition];
}

- (void)setSamplePosition:(AKParameter *)samplePosition {
    _samplePosition = samplePosition;
    [self setUpConnections];
}

- (void)setOptionalSamplePosition:(AKParameter *)samplePosition {
    [self setSamplePosition:samplePosition];
}

- (void)setReflectionCoefficient:(AKParameter *)reflectionCoefficient {
    _reflectionCoefficient = reflectionCoefficient;
    [self setUpConnections];
}

- (void)setOptionalReflectionCoefficient:(AKParameter *)reflectionCoefficient {
    [self setReflectionCoefficient:reflectionCoefficient];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _pluckPosition, _samplePosition, _reflectionCoefficient, _amplitude, _excitationSignal];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"repluck("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ repluck ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    [inputsString appendFormat:@"%@, ", _pluckPosition];
    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [inputsString appendFormat:@"%@, ", _frequency];
    
    if ([_samplePosition class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _samplePosition];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _samplePosition];
    }

    if ([_reflectionCoefficient class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _reflectionCoefficient];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _reflectionCoefficient];
    }

    if ([_excitationSignal class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@", _excitationSignal];
    } else {
        [inputsString appendFormat:@"AKAudio(%@)", _excitationSignal];
    }
    return inputsString;
}

@end
