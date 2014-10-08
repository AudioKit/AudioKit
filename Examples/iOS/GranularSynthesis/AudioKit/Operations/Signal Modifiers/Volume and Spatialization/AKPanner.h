//
//  AKPanner.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/24/12.
//  Modified by Aurelius Prochazka to add pan methods.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Distribute an audio signal across two channels with a choice of methods.
 
 Panning methods include equal power, square root, simple linear, and an
 alternative equal power method based on the MIDI Association Recommend
 Practice for GM2 RP036 (Default Pan Curve).
 */

typedef enum
{
    kPanEqualPower = 0,
    kPanSquareRoot = 1,
    kPanLinear = 2,
    kPanAltEqualPower = 3,
} PanMethod;

@interface AKPanner : AKStereoAudio

/// Instantiates the panner
/// @param audioSource Source signal.
/// @param pan From hard left (0) to hard right (1).
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                                pan:(AKParameter *)pan;


/// Set an optional pan method
/// @param panMethod Pan Method
- (void)setOptionalPanMethod:(PanMethod)panMethod;


@end