//
//  AKADSREnvelope.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Calculates the classical ADSR envelope using exponential segments.

 The envelope generated is the range 0 to 1 and may need to be scaled further, depending on the amplitude required. The length of the sustain is calculated from the length of the note. This means this operation is not suitable for use with MIDI events.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKADSREnvelope : AKControl
/// Instantiates the adsr envelope with all values
/// @param attackDuration Duration of attack phase in seconds [Default Value: 0.1]
/// @param decayDuration Duration of decay in seconds [Default Value: 0.1]
/// @param sustainLevel Level for sustain phase [Default Value: 0.5]
/// @param releaseDuration Duration of release phase in seconds. [Default Value: 1]
/// @param delay Period of zero before the envelope starts [Default Value: 0]
- (instancetype)initWithAttackDuration:(AKConstant *)attackDuration
                         decayDuration:(AKConstant *)decayDuration
                          sustainLevel:(AKConstant *)sustainLevel
                       releaseDuration:(AKConstant *)releaseDuration
                                 delay:(AKConstant *)delay;

/// Instantiates the adsr envelope with default values
- (instancetype)init;

/// Instantiates the adsr envelope with default values
+ (instancetype)envelope;


/// Duration of attack phase in seconds [Default Value: 0.1]
@property (nonatomic) AKConstant *attackDuration;

/// Set an optional attack duration
/// @param attackDuration Duration of attack phase in seconds [Default Value: 0.1]
- (void)setOptionalAttackDuration:(AKConstant *)attackDuration;

/// Duration of decay in seconds [Default Value: 0.1]
@property (nonatomic) AKConstant *decayDuration;

/// Set an optional decay duration
/// @param decayDuration Duration of decay in seconds [Default Value: 0.1]
- (void)setOptionalDecayDuration:(AKConstant *)decayDuration;

/// Level for sustain phase [Default Value: 0.5]
@property (nonatomic) AKConstant *sustainLevel;

/// Set an optional sustain level
/// @param sustainLevel Level for sustain phase [Default Value: 0.5]
- (void)setOptionalSustainLevel:(AKConstant *)sustainLevel;

/// Duration of release phase in seconds. [Default Value: 1]
@property (nonatomic) AKConstant *releaseDuration;

/// Set an optional release duration
/// @param releaseDuration Duration of release phase in seconds. [Default Value: 1]
- (void)setOptionalReleaseDuration:(AKConstant *)releaseDuration;

/// Period of zero before the envelope starts [Default Value: 0]
@property (nonatomic) AKConstant *delay;

/// Set an optional delay
/// @param delay Period of zero before the envelope starts [Default Value: 0]
- (void)setOptionalDelay:(AKConstant *)delay;



@end
NS_ASSUME_NONNULL_END
