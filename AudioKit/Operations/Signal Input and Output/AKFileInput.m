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
    AKControl *kpitch;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifilcod = fileName;
        kpitch = akp(1);
    }
    return self; 
}

- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKControl *)speed
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifilcod = fileName;
        kpitch = speed;
    }
    return self;
}

// Csound Prototype:
// a1[, a2[, ... aN]] diskin2 ifilcod, kpitch[, iskiptim [, iwrap[, iformat [, iwsize[, ibufsize[, iskipinit]]]]]]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ diskin2 \"%@\", %@, 0, 1",
            self, ifilcod, kpitch];
}


@end
