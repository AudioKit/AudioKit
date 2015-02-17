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
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKParameter *)speed
                       startTime:(AKConstant *)startTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = speed;
        _startTime = startTime;
    }
    return self;
}

- (void)setOptionalSpeed:(AKParameter *)speed {
    _speed = speed;
}
- (void)setOptionalStartTime:(AKConstant *)startTime {
    _startTime = startTime;
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:
     @"%@ diskin \"%@\", AKControl(%@), %@, 1\n",
     self, _filename, _speed, _startTime];

    return csdString;
}



@end
