//
//  AKMonoSoundFileLooper.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's loscil3:
//  http://www.csounds.com/manual/html/loscil3.html
//

#import "AKMonoSoundFileLooper.h"
#import "AKManager.h"

@implementation AKMonoSoundFileLooper
{
    AKFunctionTable * _soundFile;
}

+ (AKConstant *)loopPlaysOnce                    { return akp(0); }
+ (AKConstant *)loopRepeats                      { return akp(1); }
+ (AKConstant *)loopPlaysForwardAndThenBackwards { return akp(2); }

- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFile
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
    }
    return self;
}

- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFile
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _soundFile = soundFile;
        // Default Values
        _frequencyRatio = akp(1);
        _amplitude = akp(1);
        _loopMode = [AKMonoSoundFileLooper loopRepeats];
    }
    return self;
}

+ (instancetype)looperWithSoundFile:(AKFunctionTable *)soundFile
{
    return [[AKMonoSoundFileLooper alloc] initWithSoundFile:soundFile];
}

- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio {
    _frequencyRatio = frequencyRatio;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalLoopMode:(AKConstant *)loopMode {
    _loopMode = loopMode;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_baseFrequency = akp(1);        
    [csdString appendFormat:@"%@ loscil3 ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    if ([_frequencyRatio class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequencyRatio];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequencyRatio];
    }

    [csdString appendFormat:@"%@, ", _soundFile];
    
    [csdString appendFormat:@"%@, ", _baseFrequency];
    
    [csdString appendFormat:@"%@", _loopMode];
    return csdString;
}

@end
