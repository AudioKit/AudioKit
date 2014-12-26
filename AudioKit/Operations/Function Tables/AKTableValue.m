//
//  AKTableValue.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKTableValue.h"

@implementation AKTableValue
{
    AKConstant  *ifn;
    AKAudio *andx;
    AKParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}

- (instancetype)initWithFunctionTable:(AKConstant *)functionTable
                              atIndex:(AKAudio *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = functionTable;
        normalizeResult = NO;
        ixoff = akpi(0);
        wrapData = NO;
        andx = index;
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
            self, andx, ifn, ixmode, ixoff, iwrap];
}

@end
