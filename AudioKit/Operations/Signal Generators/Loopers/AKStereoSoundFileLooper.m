//
//  AKStereoSoundFileLooper.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add type helpers
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's loscil3:
//  http://www.csounds.com/manual/html/loscil3.html
//

#import "AKStereoSoundFileLooper.h"
#import "AKManager.h"

@implementation AKStereoSoundFileLooper
{
    AKTable * _soundFile;
}

+ (AKConstant *)loopPlaysOnce                    { return akp(0); }
+ (AKConstant *)loopRepeats                      { return akp(1); }
+ (AKConstant *)loopPlaysForwardAndThenBackwards { return akp(2); }

- (instancetype)initWithSoundFile:(AKTable *)soundFile
                   frequencyRatio:(AKParameter *)frequencyRatio
                        amplitude:(AKParameter *)amplitude
                         loopMode:(AKConstant *)loopMode
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFile = soundFile;
        _frequencyRatio = frequencyRatio;
        _amplitude = amplitude;
        _loopMode = loopMode;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithSoundFile:(AKTable *)soundFile
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFile = soundFile;
        // Default Values
        _frequencyRatio = akp(1);
        _amplitude = akp(0.5);
        _loopMode = [AKStereoSoundFileLooper loopRepeats];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)looperWithSoundFile:(AKTable *)soundFile
{
    return [[AKStereoSoundFileLooper alloc] initWithSoundFile:soundFile];
}

- (void)setFrequencyRatio:(AKParameter *)frequencyRatio {
    _frequencyRatio = frequencyRatio;
    [self setUpConnections];
}

- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio {
    [self setFrequencyRatio:frequencyRatio];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setLoopMode:(AKConstant *)loopMode {
    _loopMode = loopMode;
    [self setUpConnections];
}

- (void)setOptionalLoopMode:(AKConstant *)loopMode {
    [self setLoopMode:loopMode];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequencyRatio, _amplitude, _loopMode];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"loscil3("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ loscil3 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_baseFrequency = akp(1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    if ([_frequencyRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyRatio];
    }

    [inputsString appendFormat:@"%@, ", _soundFile];
    
    [inputsString appendFormat:@"%@, ", _baseFrequency];
    
    [inputsString appendFormat:@"%@", _loopMode];
    return inputsString;
}

@end
