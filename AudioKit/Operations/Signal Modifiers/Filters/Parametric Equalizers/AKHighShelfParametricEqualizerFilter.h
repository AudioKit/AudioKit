//
//  AKHighShelfParametricEqualizerFilter.h
//  AudioKit
//
//  Auto-generated on 6/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Implementation of Zoelzer's parametric equalizer filters

 
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKHighShelfParametricEqualizerFilter : AKAudio
/// Instantiates the high shelf parametric equalizer filter with all values
/// @param input Source audio [Default Value: ]
/// @param cornerFrequency Corner frequency Updated at Control-rate. [Default Value: ]
/// @param resonance Q of the filter sqrt(0.5) is no resonance Updated at Control-rate. [Default Value: 0.707]
/// @param gain Amount or boost or cut.  Value of 1 is a flat response. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithInput:(AKParameter *)input
              cornerFrequency:(AKParameter *)cornerFrequency
                    resonance:(AKParameter *)resonance
                         gain:(AKParameter *)gain;

/// Instantiates the high shelf parametric equalizer filter with default values
/// @param input Source audio
/// @param cornerFrequency Corner frequency
- (instancetype)initWithInput:(AKParameter *)input
              cornerFrequency:(AKParameter *)cornerFrequency;

/// Instantiates the high shelf parametric equalizer filter with default values
/// @param input Source audio
/// @param cornerFrequency Corner frequency
+ (instancetype)WithInput:(AKParameter *)input
          cornerFrequency:(AKParameter *)cornerFrequency;

/// Q of the filter sqrt(0.5) is no resonance [Default Value: 0.707]
@property (nonatomic) AKParameter *resonance;

/// Set an optional resonance
/// @param resonance Q of the filter sqrt(0.5) is no resonance Updated at Control-rate. [Default Value: 0.707]
- (void)setOptionalResonance:(AKParameter *)resonance;

/// Amount or boost or cut.  Value of 1 is a flat response. [Default Value: 1]
@property (nonatomic) AKParameter *gain;

/// Set an optional gain
/// @param gain Amount or boost or cut.  Value of 1 is a flat response. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalGain:(AKParameter *)gain;



@end
NS_ASSUME_NONNULL_END

