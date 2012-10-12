//
//  OCSTableValueControl.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValueControl.h"

@interface OCSTableValueControl () {
    OCSControl *ares;
    OCSConstant  *ifn;
    OCSParameter *andx;
    OCSParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}
@end

@implementation OCSTableValueControl

- (id)initWithFTable:(OCSConstant *)fTable
             atIndex:(OCSControl *)index
{
    self = [super init];
    if (self) {
        ares = [OCSControl parameterWithString:[self operationName]];
        ifn  = fTable;
        normalizeResult = NO;
        ixoff = [OCSConstant parameterWithInt:0];
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

- (void)offsetBy:(OCSConstant *)offsetAmount {
    ixoff = offsetAmount;
}

- (NSString *)stringForCSD
{
    int ixmode = normalizeResult ? 0:1;
    int iwrap = wrapData ? 0:1;
    return [NSString stringWithFormat:@"%@ tablei %@, %@, %i, %@, %i", ares, andx, ifn, ixmode, ixoff, iwrap];
}

- (NSString *)description {
    return [ares parameterString];
}

@end
