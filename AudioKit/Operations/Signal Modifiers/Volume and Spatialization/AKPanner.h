//
//  AKPanner.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Distribute an audio signal across two channels with a choice of methods.

 Panning methods include equal power, square root, simple linear, and an alternative equal power method based on the MIDI Association Recommend Practice for GM2 RP036 (Default Pan Curve).
 */

@interface AKPanner : AKStereoAudio
/// Instantiates the panner with all values
/// @param audioSource Source signal. [Default Value: ]
/// @param pan From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
/// @param panMethod Pan Method: EqualPower = 0, SquareRoot = 1, Linear = 2, AltEqualPower = 3 [Default Value: 0]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                                pan:(AKParameter *)pan
                          panMethod:(AKConstant *)panMethod;

/// Instantiates the panner with default values
/// @param audioSource Source signal.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the panner with default values
/// @param audioSource Source signal.
+ (instancetype)stereoaudioWithAudioSource:(AKAudio *)audioSource;

/// From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
@property AKParameter *pan;

/// Set an optional pan
/// @param pan From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
- (void)setOptionalPan:(AKParameter *)pan;

/// Pan Method: EqualPower = 0, SquareRoot = 1, Linear = 2, AltEqualPower = 3 [Default Value: 0]
@property AKConstant *panMethod;

/// Set an optional pan method
/// @param panMethod Pan Method: EqualPower = 0, SquareRoot = 1, Linear = 2, AltEqualPower = 3 [Default Value: 0]
- (void)setOptionalPanMethod:(AKConstant *)panMethod;



@end
