//
//  AKPanner.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazk to add type helpers
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Distribute an audio signal across two channels with a choice of methods.

 Panning methods include equal power, square root, simple linear, and an alternative equal power method based on the MIDI Association Recommend Practice for GM2 RP036 (Default Pan Curve).
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKPanner : AKStereoAudio

// Type Helpers

/// Maintains equal power during panning
+ (AKConstant *)panMethodForEqualPower;

/// Square root method for determining pan output
+ (AKConstant *)panMethodForSquareRoot;

/// Straight linear variation in the panning
+ (AKConstant *)panMethodForLinear;

/// Another equal power method
+ (AKConstant *)panMethodForEqualPowerAlternate;

/// Instantiates the panner with all values
/// @param input Source signal. 
/// @param pan From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
/// @param panMethod AKPanMethod can be EqualPower, SquareRoot, Linear, AltEqualPower [Default Value: AKPanMethodEqualPower]
- (instancetype)initWithInput:(AKParameter *)input
                          pan:(AKParameter *)pan
                    panMethod:(AKConstant *)panMethod;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
+ (instancetype)pannerWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
- (instancetype)initWithPresetDefaultCenteredWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
+ (instancetype)presetDefaultCenteredWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
- (instancetype)initWithPresetDefaultHardLeftWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
+ (instancetype)presetDefaultHardLeftWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
- (instancetype)initWithPresetDefaultHardRighWithInput:(AKParameter *)input;

/// Instantiates the panner with default (centered) values
/// @param input Source signal.
+ (instancetype)presetDefaultHardRighWithInput:(AKParameter *)input;


/// From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
@property (nonatomic) AKParameter *pan;

/// Set an optional pan
/// @param pan From hard left (-1) to middle (0) to hard right (1). [Default Value: 0]
- (void)setOptionalPan:(AKParameter *)pan;

/// AKPanMethod can be EqualPower, SquareRoot, Linear, AltEqualPower [Default Value: AKPanMethodEqualPower]
@property (nonatomic) AKConstant *panMethod;

/// Set an optional pan method
/// @param panMethod AKPanMethod can be EqualPower, SquareRoot, Linear, AltEqualPower [Default Value: AKPanMethodEqualPower]
- (void)setOptionalPanMethod:(AKConstant *)panMethod;



@end
NS_ASSUME_NONNULL_END
