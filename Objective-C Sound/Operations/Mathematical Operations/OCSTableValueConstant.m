//
//  OCSTableValueConstant.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValueConstant.h"

@interface OCSTableValueConstant () {
    OCSConstant *ares;
    OCSConstant  *ifn;
    OCSParameter *andx;
    OCSParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}
@end

@implementation OCSTableValueConstant

- (id)initWithFTable:(OCSConstant *)fTable
             atIndex:(OCSConstant *)index
{
    self = [super init];
    if (self) {
        ares = [OCSConstant parameterWithString:[self operationName]];
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
