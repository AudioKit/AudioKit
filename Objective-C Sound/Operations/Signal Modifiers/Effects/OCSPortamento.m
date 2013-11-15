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
    OCSConstant *isig;
}
@end

@implementation OCSPortamento

- (instancetype)initWithControlSource:(OCSControl *)controlSource
                   halfTime:(OCSControl *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ksig = controlSource;
        khtim = halfTime;
        isig = ocsp(0);
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ portk %@, %@, %@",
            self, ksig, khtim, isig];
}

- (void)setOptionalFeedbackAmount:(OCSConstant *)feedback
{
    isig = feedback;
}

@end