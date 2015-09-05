//
//  AKManager.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"
#import "soundpipe.h"

@interface AKManager : NSObject
@property (nonatomic) sp_data *data;
@property (nonatomic, retain) AKInstrument *instrument;

- (void)destroy;

/// @returns the shared instance of AKManager
+ (AKManager *)sharedManager;

@end
