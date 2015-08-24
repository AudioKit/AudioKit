//
//  AKSoundFontPresetPlayer.m
//  AudioKit
//
//  Auto-generated on 6/12/15. Customized by Aurelius Prochazka on 6/30/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sfplay3:
//  http://www.csounds.com/manual/html/sfplay3.html
//

#import "AKSoundFontPresetPlayer.h"
#import "AKFoundation.h"

@implementation AKSoundFontPresetPlayer
{
    AKSoundFontPreset * _soundFontPreset;
}

- (instancetype)initWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset
                             noteNumber:(AKConstant *)noteNumber
                               velocity:(AKConstant *)velocity
                    frequencyMultiplier:(AKParameter *)frequencyMultiplier
                              amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFontPreset = soundFontPreset;
        [[[AKManager sharedManager] engine] updateOrchestra:[soundFontPreset orchestraString]];
        _noteNumber = noteNumber;
        _velocity = velocity;
        _frequencyMultiplier = frequencyMultiplier;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _soundFontPreset = soundFontPreset;
        [[[AKManager sharedManager] engine] updateOrchestra:[soundFontPreset orchestraString]];

        _noteNumber = akp(60);
        _velocity = akp(1);
        _frequencyMultiplier = akp(1);
        _amplitude = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)playerWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset
{
    return [[AKSoundFontPresetPlayer alloc] initWithSoundFontPreset:soundFontPreset];
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

    [inputsString appendFormat:@"%@/127, ", _velocity];
    
    [inputsString appendFormat:@"%@, ", _noteNumber];
    
    [inputsString appendFormat:@"%@*%@/(3000*127), ", _velocity, _amplitude];
    
    [inputsString appendFormat:@"%@, ", _frequencyMultiplier];
    
    [inputsString appendFormat:@"%@", _soundFontPreset];
    return inputsString;
}

@end
