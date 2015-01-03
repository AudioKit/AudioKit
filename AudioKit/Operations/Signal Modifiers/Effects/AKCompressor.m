//
//  AKCompressor.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
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
    }
    return self;
}

+ (instancetype)compressorWithInput:(AKParameter *)input
                   controllingInput:(AKParameter *)controllingInput
{
    return [[AKCompressor alloc] initWithInput:input
                              controllingInput:controllingInput];
}

- (void)setOptionalThreshold:(AKParameter *)threshold {
    _threshold = threshold;
}
- (void)setOptionalLowKnee:(AKParameter *)lowKnee {
    _lowKnee = lowKnee;
}
- (void)setOptionalHighKnee:(AKParameter *)highKnee {
    _highKnee = highKnee;
}
- (void)setOptionalCompressionRatio:(AKParameter *)compressionRatio {
    _compressionRatio = compressionRatio;
}
- (void)setOptionalAttackTime:(AKParameter *)attackTime {
    _attackTime = attackTime;
}
- (void)setOptionalReleaseTime:(AKParameter *)releaseTime {
    _releaseTime = releaseTime;
}
- (void)setOptionalLookAheadTime:(AKConstant *)lookAheadTime {
    _lookAheadTime = lookAheadTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ compress ", self];
    
    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }
    
    if ([_controllingInput class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _controllingInput];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _controllingInput];
    }
    
    if ([_threshold class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _threshold];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _threshold];
    }
    
    if ([_lowKnee class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _lowKnee];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _lowKnee];
    }
    
    if ([_highKnee class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _highKnee];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _highKnee];
    }
    
    if ([_compressionRatio class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _compressionRatio];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _compressionRatio];
    }
    
    if ([_attackTime class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _attackTime];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _attackTime];
    }
    
    if ([_releaseTime class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _releaseTime];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _releaseTime];
    }
    
    [csdString appendFormat:@"%@", _lookAheadTime];
    return csdString;
}

@end
