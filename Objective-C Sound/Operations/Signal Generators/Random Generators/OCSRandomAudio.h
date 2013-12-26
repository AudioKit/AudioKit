//
//  OCSRandomAudio.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Generates a controlled pseudo-random number series between min and max values.
 */

@interface OCSRandomAudio : OCSAudio

/// Instantiates the random audio
/// @param minimum Minimum range limit.
/// @param maximum Maximum range limit
- (instancetype)initWithMinimum:(OCSControl *)minimum
                        maximum:(OCSControl *)maximum;

@end