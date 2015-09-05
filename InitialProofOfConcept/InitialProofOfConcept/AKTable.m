//
//  AKTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

// implement variable size and different standard waveforms and such

#import "AKTable.h"

@implementation AKTable {
    sp_ftbl *ft;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self create];
    }
    return self;
}
- (void)create
{
    AKManager *manager = [AKManager sharedManager];
    sp_ftbl_create(manager.data, &ft, 4096);
    sp_gen_sine(manager.data, ft);
}

- (void)destroy
{
    sp_ftbl_destroy(&ft);
}

- (sp_ftbl *)table
{
    return ft;
}


@end
