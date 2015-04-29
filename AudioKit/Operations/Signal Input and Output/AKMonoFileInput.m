//
//  AKMonoFileInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's diskin2:
//  http://www.csounds.com/manual/html/diskin2.html
//

#import "AKMonoFileInput.h"

@implementation AKMonoFileInput
{
    NSString *_filename;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = akp(1);
        _startTime = akp(0);
        _loop = NO;
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

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_speed, _startTime];
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:
     @"%@ diskin \"%@\", AKControl(%@), %@, %d\n",
     self, _filename, _speed, _startTime, _loop];
    
    return csdString;
}



@end
