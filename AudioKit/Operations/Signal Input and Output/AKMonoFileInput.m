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
    NSString *ifilcod;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifilcod = fileName;
    }
    return self;
}

// Csound Prototype:
// a1[, a2[, ... aN]] diskin ifilcod, kpitch[, iskiptim [, iwrap[, iformat [, iwsize[, ibufsize[, iskipinit]]]]]]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ diskin \"%@\", 1, 0, 1",
            self, ifilcod];
}


@end
