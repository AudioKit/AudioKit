//
//  OCSDeclick.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Removes clicks from signal start and end
 
 Given a signal, declick will apply an envelope to ensure there is no clicking at the start or end of the sound.
 */

@interface OCSDeclick : OCSAudio

/// Instantiates the declick
/// @param sourceAudio Audio to declick
- (id)initWithSourceAudio:(OCSAudio *)sourceAudio;

@end