//
//  AKCompressor.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's compress:
//  http://www.csounds.com/manual/html/compress.html
//

#import "AKCompressor.h"
#import "AKManager.h"

@implementation AKCompressor
{
    AKParameter * _input;
    AKParameter * _controllingInput;
}

- (instancetype)initWithInput:(AKParameter *)input
             controllingInput:(AKParameter *)controllingInput
                    threshold:(AKParameter *)threshold
                      lowKnee:(AKParameter *)lowKnee
                     highKnee:(AKParameter *)highKnee
             compressionRatio:(AKParameter *)compressionRatio
                   attackTime:(AKParameter *)attackTime
                  releaseTime:(AKParameter *)releaseTime
                lookAheadTime:(AKConstant *)lookAheadTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _controllingInput = controllingInput;
        _threshold = threshold;
        _lowKnee = lowKnee;
        _highKnee = highKnee;
        _compressionRatio = compressionRatio;
        _attackTime = attackTime;
        _releaseTime = releaseTime;
        _lookAheadTime = lookAheadTime;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
             controllingInput:(AKParameter *)controllingInput
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _controllingInput = controllingInput;
        // Default Values
        _threshold = akp(0);
        _lowKnee = akp(48);
        _highKnee = akp(60);
        _compressionRatio = akp(1);
        _attackTime = akp(0.1);
        _releaseTime = akp(1);
        _lookAheadTime = akp(0.05);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)compressorWithInput:(AKParameter *)input
                  controllingInput:(AKParameter *)controllingInput
{
    return [[AKCompressor alloc] initWithInput:input
                  controllingInput:controllingInput];
}

- (void)setThreshold:(AKParameter *)threshold {
    _threshold = threshold;
    [self setUpConnections];
}

- (void)setOptionalThreshold:(AKParameter *)threshold {
    [self setThreshold:threshold];
}

- (void)setLowKnee:(AKParameter *)lowKnee {
    _lowKnee = lowKnee;
    [self setUpConnections];
}

- (void)setOptionalLowKnee:(AKParameter *)lowKnee {
    [self setLowKnee:lowKnee];
}

- (void)setHighKnee:(AKParameter *)highKnee {
    _highKnee = highKnee;
    [self setUpConnections];
}

- (void)setOptionalHighKnee:(AKParameter *)highKnee {
    [self setHighKnee:highKnee];
}

- (void)setCompressionRatio:(AKParameter *)compressionRatio {
    _compressionRatio = compressionRatio;
    [self setUpConnections];
}

- (void)setOptionalCompressionRatio:(AKParameter *)compressionRatio {
    [self setCompressionRatio:compressionRatio];
}

- (void)setAttackTime:(AKParameter *)attackTime {
    _attackTime = attackTime;
    [self setUpConnections];
}

- (void)setOptionalAttackTime:(AKParameter *)attackTime {
    [self setAttackTime:attackTime];
}

- (void)setReleaseTime:(AKParameter *)releaseTime {
    _releaseTime = releaseTime;
    [self setUpConnections];
}

- (void)setOptionalReleaseTime:(AKParameter *)releaseTime {
    [self setReleaseTime:releaseTime];
}

- (void)setLookAheadTime:(AKConstant *)lookAheadTime {
    _lookAheadTime = lookAheadTime;
    [self setUpConnections];
}

- (void)setOptionalLookAheadTime:(AKConstant *)lookAheadTime {
    [self setLookAheadTime:lookAheadTime];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _controllingInput, _threshold, _lowKnee, _highKnee, _compressionRatio, _attackTime, _releaseTime, _lookAheadTime];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"compress("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ compress ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_controllingInput class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _controllingInput];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _controllingInput];
    }

    if ([_threshold class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _threshold];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _threshold];
    }

    if ([_lowKnee class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _lowKnee];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _lowKnee];
    }

    if ([_highKnee class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _highKnee];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _highKnee];
    }

    if ([_compressionRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _compressionRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _compressionRatio];
    }

    if ([_attackTime class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _attackTime];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _attackTime];
    }

    if ([_releaseTime class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _releaseTime];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _releaseTime];
    }

    [inputsString appendFormat:@"%@", _lookAheadTime];
    return inputsString;
}

@end
