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
    AKFunctionTable *ifn;
    AKParameter *andx;
    AKParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                              atIndex:(AKParameter *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = functionTable;
        normalizeResult = NO;
        ixoff = akpi(0);
        wrapData = NO;
        andx = index;
        self.state = @"connectable";
        self.dependencies = @[ifn, index];
    }
    return self;
    
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
            @"%@ tablei AKAudio(%@), %@, %i, %@, %i",
            self, andx, ifn, ixmode, ixoff, iwrap];
}

@end
