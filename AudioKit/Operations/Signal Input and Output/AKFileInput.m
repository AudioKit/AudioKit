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
    NSString *ifilcod;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifilcod = fileName;
        _speed = akp(1);
    }
    return self; 
}

- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKControl *)speed
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifilcod = fileName;
        _speed = speed;
    }
    return self;
}

- (void)setOptionalSpeed:(AKParameter *)speed {
    _speed = speed;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ diskin2 \"%@\", AKControl(%@), 0, 1",
            self, ifilcod, _speed];
}


@end
