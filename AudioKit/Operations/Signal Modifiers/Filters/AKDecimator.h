//
//  AKDecimator.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Sample rate / Bit depth reduction.

 This operation implements one possible algorithm for sample rate / bit depth reduction.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKDecimator : AKAudio
/// Instantiates the decimator with all values
/// @param input Audio to be decimated! 
/// @param bitDepth The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. Updated at Control-rate. [Default Value: 24]
/// @param sampleRate The sample rate of signal output. Non-integer values are OK. Updated at Control-rate. [Default Value: 44100]
- (instancetype)initWithInput:(AKParameter *)input
                     bitDepth:(AKParameter *)bitDepth
                   sampleRate:(AKParameter *)sampleRate;

/// Instantiates the decimator with default values
/// @param input Audio to be decimated!
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the decimator with default values
/// @param input Audio to be decimated!
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the decimator with default values
/// @param input Audio to be decimated!
- (instancetype)initWithPresetDefaultDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with default values
/// @param input Audio to be decimated!
+ (instancetype)presetDefaultDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a crunchy sound
/// @param input Audio to be decimated!
- (instancetype)initWithPresetCrunchyDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a crunchy sound
/// @param input Audio to be decimated!
+ (instancetype)presetCrunchyDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a 'videogame' sound
/// @param input Audio to be decimated!
- (instancetype)initWithPresetVideogameDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a 'videogame' sound
/// @param input Audio to be decimated!
+ (instancetype)presetVideogameDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a 'robot' sound
/// @param input Audio to be decimated!
- (instancetype)initWithPresetRobotDecimatorWithInput:(AKParameter *)input;

/// Instantiates the decimator with a 'robot' sound
/// @param input Audio to be decimated!
+ (instancetype)presetRobotDecimatorWithInput:(AKParameter *)input;


/// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. [Default Value: 24]
@property (nonatomic) AKParameter *bitDepth;

/// Set an optional bit depth
/// @param bitDepth The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. Updated at Control-rate. [Default Value: 24]
- (void)setOptionalBitDepth:(AKParameter *)bitDepth;

/// The sample rate of signal output. Non-integer values are OK. [Default Value: 44100]
@property (nonatomic) AKParameter *sampleRate;

/// Set an optional sample rate
/// @param sampleRate The sample rate of signal output. Non-integer values are OK. Updated at Control-rate. [Default Value: 44100]
- (void)setOptionalSampleRate:(AKParameter *)sampleRate;



@end
NS_ASSUME_NONNULL_END
