//
//  AKDeclick.h
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Declick operation to prevent clicks at the stop of the input signal
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKDeclick : AKAudio
/// Instantiates the declick with all values
/// @param input Input audio signal to be declicked 
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the declick with default values
/// @param input Input audio signal to be declicked
+ (instancetype)WithInput:(AKParameter *)input;

@end
NS_ASSUME_NONNULL_END
