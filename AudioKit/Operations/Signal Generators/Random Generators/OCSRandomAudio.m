//
//  OCSRandomAudio.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's random:
//  http://www.csounds.com/manual/html/random.html
//

#import "OCSRandomAudio.h"

@interface OCSRandomAudio () {
    OCSControl *kmin;
    OCSControl *kmax;
}
@end

@implementation OCSRandomAudio

- (instancetype)initWithMinimum:(OCSControl *)minimum
                        maximum:(OCSControl *)maximum
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kmin = minimum;
        kmax = maximum;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ random %@, %@",
            self, kmin, kmax];
}

@end