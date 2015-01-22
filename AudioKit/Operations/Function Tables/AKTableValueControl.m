//
//  AKTableValueControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKTableValueControl.h"

@implementation AKTableValueControl
{
    AKConstant  *ifn;
    AKControl  *kndx;
    AKParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}

- (instancetype)initWithFunctionTable:(AKConstant *)functionTable
                              atIndex:(AKControl *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = functionTable;
        normalizeResult = NO;
        ixoff = akpi(0);
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

- (void)offsetBy:(AKConstant *)offsetAmount {
    ixoff = offsetAmount;
}

- (NSString *)stringForCSD
{
    int ixmode = normalizeResult ? 0:1;
    int iwrap = wrapData ? 0:1;
    return [NSString stringWithFormat:
            @"%@ tablei AKControl(%@), %@, %i, %@, %i",
            self, kndx, ifn, ixmode, ixoff, iwrap];
}

@end
