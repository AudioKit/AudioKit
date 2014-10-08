//
//  AKPortamento.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's portk:
//  http://www.csounds.com/manual/html/portk.html
//

#import "AKPortamento.h"

@implementation AKPortamento
{
    AKControl *ksig;
    AKControl *khtim;
    AKConstant *isig;
}

- (instancetype)initWithControlSource:(AKControl *)controlSource
                             halfTime:(AKControl *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ksig = controlSource;
        khtim = halfTime;
        isig = akp(0);
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ portk %@, %@, %@",
            self, ksig, khtim, isig];
}

- (void)setOptionalFeedbackAmount:(AKConstant *)feedback
{
    isig = feedback;
}

@end