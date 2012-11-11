//
//  OCSTableValue.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValue.h"

@interface OCSTableValue () {
    OCSConstant  *ifn;
    OCSAudio *andx;
    OCSParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}
@end

@implementation OCSTableValue

- (id)initWithFTable:(OCSConstant *)fTable
             atIndex:(OCSAudio *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = fTable;
        normalizeResult = NO;
        ixoff = ocspi(0);
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
    return [NSString stringWithFormat:
            @"%@ tablei %@, %@, %i, %@, %i",
            self, andx, ifn, ixmode, ixoff, iwrap];
}

@end
