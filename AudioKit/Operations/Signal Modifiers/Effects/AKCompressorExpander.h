//
//  AKCompressorExpander.h
//  AudioKit
//
//  Auto-generated on 10/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Dynamic Compressor / Expander

 This operation dynamically modifies a gain value applied to the input sound by comparing its power level to a given threshold level. The signal will be compressed/expanded with different factors regarding that it is over or under the threshold.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKCompressorExpander : AKAudio
/// Instantiates the compressor expander with all values
/// @param input Audio signal [Default Value: ]
/// @param threshold Level of input signal which acts as the threshold Updated at Control-rate. [Default Value: 1]
/// @param lowerRatio Compression ratio for lower zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
/// @param upperRatio Compression ratio for upper zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
/// @param attackTime Gain rise time in seconds. Time over which the gain factor is allowed to raise of one unit. [Default Value: 0.05]
/// @param releaseTime Gain fall time in seconds. Time over which the gain factor is allowed to decrease of one unit. [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
                    threshold:(AKParameter *)threshold
                   lowerRatio:(AKConstant *)lowerRatio
                   upperRatio:(AKConstant *)upperRatio
                   attackTime:(AKConstant *)attackTime
                  releaseTime:(AKConstant *)releaseTime;

/// Instantiates the compressor expander with default values
/// @param input Audio signal
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the compressor expander with default values
/// @param input Audio signal
+ (instancetype)compressorWithInput:(AKParameter *)input;

/// Level of input signal which acts as the threshold [Default Value: 1]
@property (nonatomic) AKParameter *threshold;

/// Set an optional threshold
/// @param threshold Level of input signal which acts as the threshold Updated at Control-rate. [Default Value: 1]
- (void)setOptionalThreshold:(AKParameter *)threshold;

/// Compression ratio for lower zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
@property (nonatomic) AKConstant *lowerRatio;

/// Set an optional lower ratio
/// @param lowerRatio Compression ratio for lower zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
- (void)setOptionalLowerRatio:(AKConstant *)lowerRatio;

/// Compression ratio for upper zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
@property (nonatomic) AKConstant *upperRatio;

/// Set an optional upper ratio
/// @param upperRatio Compression ratio for upper zone. Value less than 1 is compressors, greater than 1 for expanders. [Default Value: 1]
- (void)setOptionalUpperRatio:(AKConstant *)upperRatio;

/// Gain rise time in seconds. Time over which the gain factor is allowed to raise of one unit. [Default Value: 0.05]
@property (nonatomic) AKConstant *attackTime;

/// Set an optional attack time
/// @param attackTime Gain rise time in seconds. Time over which the gain factor is allowed to raise of one unit. [Default Value: 0.05]
- (void)setOptionalAttackTime:(AKConstant *)attackTime;

/// Gain fall time in seconds. Time over which the gain factor is allowed to decrease of one unit. [Default Value: 0.5]
@property (nonatomic) AKConstant *releaseTime;

/// Set an optional release time
/// @param releaseTime Gain fall time in seconds. Time over which the gain factor is allowed to decrease of one unit. [Default Value: 0.5]
- (void)setOptionalReleaseTime:(AKConstant *)releaseTime;



@end
NS_ASSUME_NONNULL_END

