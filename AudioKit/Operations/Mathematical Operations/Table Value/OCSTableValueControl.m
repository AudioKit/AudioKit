//
//  OCSTableValueControl.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValueControl.h"

@interface OCSTableValueControl () {
    OCSConstant  *ifn;
    OCSControl  *kndx;
    OCSParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}
@end

@implementation OCSTableValueControl

- (instancetype)initWithFTable:(OCSConstant *)fTable
                       atIndex:(OCSControl *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = fTable;
        normalizeResult = NO;
        ixoff = ocspi(0);
        wrapData = NO;
        kndx = index;
    }
    return self;
    
}

- (void)normalize {
    normalizeResult = YES;
}

- (void)wrap {
    wrapData = YES;
}

- (void)offsetBy:(OCSConstant *)offsetAmount {
    ixoff = offsetAmount;
}

- (NSString *)stringForCSD
{
    int ixmode = normalizeResult ? 0:1;
    int iwrap = wrapData ? 0:1;
    return [NSString stringWithFormat:
            @"%@ tablei %@, %@, %i, %@, %i",
            self, kndx, ifn, ixmode, ixoff, iwrap];
}

@end
