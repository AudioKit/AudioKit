//
//  AKFileInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's diskin2:
//  http://www.csounds.com/manual/html/diskin2.html
//

#import "AKFileInput.h"

@interface AKFileInput () {
    NSString *ifilcod;
}
@end

@implementation AKFileInput

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super init];
    if (self) {
        ifilcod = fileName;
    }
    return self; 
}

// Csound Prototype:
// a1[, a2[, ... aN]] diskin2 ifilcod, kpitch[, iskiptim [, iwrap[, iformat [, iwsize[, ibufsize[, iskipinit]]]]]]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ diskin2 \"%@\", 1, 0, 1",
            self, ifilcod];
}


@end
