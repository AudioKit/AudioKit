//
//  AKSoundFontInstrumentPlayer.m
//  AudioKit
//
//  Auto-generated on 6/30/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sfinstr:
//  http://www.csounds.com/manual/html/sfinstr.html
//

#import "AKSoundFontInstrumentPlayer.h"
#import "AKFoundation.h"

@implementation AKSoundFontInstrumentPlayer
{
    AKSoundFontInstrument * _soundFontInstrument;
}

- (instancetype)initWithSoundFontInstrument:(AKSoundFontInstrument *)soundFontInstrument
                                 noteNumber:(AKConstant *)noteNumber
                                   velocity:(AKConstant *)velocity
                        frequencyMultiplier:(AKParameter *)frequencyMultiplier
                                  amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFontInstrument = soundFontInstrument;
        _noteNumber = noteNumber;
        _velocity = velocity;
        _frequencyMultiplier = frequencyMultiplier;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithSoundFontInstrument:(AKSoundFontInstrument *)soundFontInstrument
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFontInstrument = soundFontInstrument;
        // Default Values
        _noteNumber = akp(60);
        _velocity = akp(1);
        _frequencyMultiplier = akp(440);
        _amplitude = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)playerWithSoundFontInstrument:(AKSoundFontInstrument *)soundFontInstrument
{
    return [[AKSoundFontInstrumentPlayer alloc] initWithSoundFontInstrument:soundFontInstrument];
}

- (void)setNoteNumber:(AKConstant *)noteNumber {
    _noteNumber = noteNumber;
    [self setUpConnections];
}

- (void)setOptionalNoteNumber:(AKConstant *)noteNumber {
    [self setNoteNumber:noteNumber];
}

- (void)setVelocity:(AKConstant *)velocity {
    _velocity = velocity;
    [self setUpConnections];
}

- (void)setOptionalVelocity:(AKConstant *)velocity {
    [self setVelocity:velocity];
}

- (void)setFrequencyMultiplier:(AKParameter *)frequencyMultiplier {
    _frequencyMultiplier = frequencyMultiplier;
    [self setUpConnections];
}

- (void)setOptionalFrequencyMultiplier:(AKParameter *)frequencyMultiplier {
    [self setFrequencyMultiplier:frequencyMultiplier];
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
    self.dependencies = @[_noteNumber, _velocity, _frequencyMultiplier, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"sfinstr("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ sfinstr ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    [inputsString appendFormat:@"%@, ", _velocity];
    
    [inputsString appendFormat:@"%@, ", _noteNumber];
    
    [inputsString appendFormat:@"%@/3000, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _frequencyMultiplier];
    
    [inputsString appendFormat:@"%@, ", @(_soundFontInstrument.number)];
    
    [inputsString appendFormat:@"%@", _soundFontInstrument.soundFont];
    return inputsString;
}

@end
