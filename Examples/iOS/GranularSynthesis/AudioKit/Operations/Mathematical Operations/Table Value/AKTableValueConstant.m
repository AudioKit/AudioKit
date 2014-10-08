//
//  AKTableValueConstant.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKTableValueConstant.h"

@implementation AKTableValueConstant
{
    AKConstant  *ifn;
    AKParameter *indx;
    AKParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}

- (instancetype)initWithFTable:(AKConstant *)fTable
                       atIndex:(AKConstant *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = fTable;
        normalizeResult = NO;
        ixoff = akpi(0);
        wrapData = NO;
        indx = index;
    }
    return self;
    
}

- (void)normalize {
    normalizeResult = YES;
}

- (void)wrap {
    wrapData = YES;
}

- (void)offsetBy:(AKConstant *)offsetAmount {
    ixoff = offsetAmount;
}

- (NSString *)stringForCSD
{
    int ixmode = normalizeResult ? 0:1;
    int iwrap = wrapData ? 0:1;
    return [NSString stringWithFormat:
            @"%@ tablei %@, %@, %i, %@, %i",
            self, indx, ifn, ixmode, ixoff, iwrap];
}

@end
