//
//  OCSPortamento.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/14/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's portk:
//  http://www.csounds.com/manual/html/portk.html
//

#import "OCSPortamento.h"

@interface OCSPortamento () {
    OCSControl *ksig;
    OCSControl *khtim;
}
@end

@implementation OCSPortamento

- (id)initWithControlSource:(OCSControl *)controlSource
                   halfTime:(OCSControl *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ksig = controlSource;
        khtim = halfTime;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ portk %@, %@",
            self, ksig, khtim];
}

@end