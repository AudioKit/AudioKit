//
//  AKManager.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKManager.h"

@implementation AKManager

- (instancetype)init
{
    NSLog(@"Initializing Manager");
    if ([super init]) {
        sp_create(&_data);
        _instrument = [[AKInstrument alloc] init];
    }
    return self;
}

- (void)destroy
{
    sp_destroy(&_data);
}

// -----------------------------------------------------------------------------
#  pragma mark - Singleton Setup
// -----------------------------------------------------------------------------

static AKManager *_sharedManager = nil;

+ (AKManager *)sharedManager
{
    @synchronized(self)
    {
        if(!_sharedManager) _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(_sharedManager == nil, @"Attempted to allocate a 2nd AKManager");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}


@end
