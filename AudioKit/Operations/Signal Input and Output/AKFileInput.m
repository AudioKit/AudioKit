//
//  AKFileInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's diskin2:
//  http://www.csounds.com/manual/html/diskin2.html
//

#import "AKFileInput.h"

@implementation AKFileInput
{
    NSString *_filename;
    BOOL isNormalized;
    float normalization;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = akp(1);
        _startTime = akp(0);
        _loop = NO;
        isNormalized = NO;
        normalization = 1;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKParameter *)speed
                       startTime:(AKConstant *)startTime
                            loop:(BOOL)loop
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = speed;
        _startTime = startTime;
        _loop = loop;
        [self setUpConnections];
    }
    return self;
}

- (void)setSpeed:(AKParameter *)speed {
    _speed = speed;
    [self setUpConnections];
}

- (void)setOptionalSpeed:(AKParameter *)speed {
    [self setSpeed:speed];
}

- (void)setStartTime:(AKConstant *)startTime {
    _startTime = startTime;
    [self setUpConnections];
}

- (void)setOptionalStartTime:(AKConstant *)startTime {
    [self setStartTime:startTime];
}

- (void)setOptionalLoop:(BOOL)loop {
    _loop = loop;
}

- (void)normalizeTo:(float)maximumAmplitude {
    isNormalized = YES;
    normalization = maximumAmplitude;
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_speed, _startTime];
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    // Determine the maximum file amplitude
    if (isNormalized) [csdString appendFormat:@"ipeak filepeak \"%@\"\n", _filename];
    
    [csdString appendFormat:
     @"%@ diskin2 \"%@\", AKControl(%@), %@, %d\n",
     self, _filename, _speed, _startTime, _loop];
    
    // Normalize the output
    if (isNormalized) {
        [csdString appendFormat:@"%@ = %f * %@ / ipeak\n",
         self.leftOutput, normalization, self.leftOutput];
        [csdString appendFormat:@"%@ = %f * %@ / ipeak",
         self.rightOutput, normalization, self.rightOutput];
    }
    return csdString;
}

@end
