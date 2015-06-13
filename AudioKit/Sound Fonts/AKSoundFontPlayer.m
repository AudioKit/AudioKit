//
//  AKSoundFontPlayer.m
//  AudioKit
//
//  Auto-generated on 6/12/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sfplay3:
//  http://www.csounds.com/manual/html/sfplay3.html
//

#import "AKSoundFontPlayer.h"
#import "AKManager.h"

@implementation AKSoundFontPlayer
{
    AKSoundFont * _soundFont;
}


- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont
                       noteNumber:(AKConstant *)noteNumber
                         velocity:(AKConstant *)velocity
              frequencyMultiplier:(AKParameter *)frequencyMultiplier
                        amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFont = soundFont;
        _noteNumber = noteNumber;
        _velocity = velocity;
        _frequencyMultiplier = frequencyMultiplier;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _soundFont = soundFont;

        _noteNumber = akp(60);
        _velocity = akp(1);
        _frequencyMultiplier = akp(1);
        _amplitude = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)playerWithSoundFont:(AKSoundFont *)soundFont
{
    return [[AKSoundFontPlayer alloc] initWithSoundFont:soundFont];
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

    [inlineCSDString appendString:@"sfplay3("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ sfplay3 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    [inputsString appendFormat:@"%@, ", _velocity];
    
    [inputsString appendFormat:@"%@, ", _noteNumber];
    
    [inputsString appendFormat:@"%@/3000, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _frequencyMultiplier];
    
    [inputsString appendFormat:@"%d", _soundFont.number];
    return inputsString;
}

@end
