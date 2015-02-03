//
//  AKDeclick.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Removes clicks from signal start and end
 
 Given a signal, declick will apply an envelope to ensure there is no clicking at the start or end of the sound.
 */

@interface AKDeclick : AKAudio

/// Instantiates the declick
/// @param audioSource Audio to declick
- (instancetype)initWithInput:(AKAudio *)audioSource;

@end