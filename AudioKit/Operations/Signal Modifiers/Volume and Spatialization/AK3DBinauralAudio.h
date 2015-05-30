//
//  AK3DBinauralAudio.h
//  AudioKit
//
//  Auto-generated on 4/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Generates dynamic 3d binaural audio for headphones using a Woodworth based spherical head model with improved low frequency phase accuracy.

 This operation takes a source signal and spatialises it in the 3 dimensional space around a listener using head related transfer function (HRTF) based filters.
Artifact-free user-defined trajectories are made possible using an interpolation algorithm based on spectral magnitude interpolation and a derived phase spectrum based on the Woodworth spherical head model. Accuracy is increased for the data set provided by extracting and applying a frequency dependent scaling factor to the phase spectra, leading to a more precise low frequency interaural time difference. Users can control head radius for the phase derivation, allowing a crude level of individualisation. The dynamic source version of the opcode uses a Short Time Fourier Transform algorithm to avoid artefacts caused by derived phase spectra changes.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AK3DBinauralAudio : AKStereoAudio
/// Instantiates the 3 d binaural audio with all values
/// @param input  Input/source signal. 
/// @param azimuth Azimuth angle in degrees. Positive values represent position on the right, negative values are positions on the left. Updated at Control-rate. [Default Value: 0]
/// @param elevation Elevation angle in degrees. Positive values represent position above horizontal, negative values are positions below horizontal (minimum: -40). Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithInput:(AKParameter *)input
                      azimuth:(AKParameter *)azimuth
                    elevation:(AKParameter *)elevation;

/// Instantiates the 3 d binaural audio with default values
/// @param input  Input/source signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the 3 d binaural audio with default values
/// @param input  Input/source signal.
+ (instancetype)WithInput:(AKParameter *)input;

/// Azimuth angle in degrees. Positive values represent position on the right, negative values are positions on the left. [Default Value: 0]
@property (nonatomic) AKParameter *azimuth;

/// Set an optional azimuth
/// @param azimuth Azimuth angle in degrees. Positive values represent position on the right, negative values are positions on the left. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalAzimuth:(AKParameter *)azimuth;

/// Elevation angle in degrees. Positive values represent position above horizontal, negative values are positions below horizontal (minimum: -40). [Default Value: 0]
@property (nonatomic) AKParameter *elevation;

/// Set an optional elevation
/// @param elevation Elevation angle in degrees. Positive values represent position above horizontal, negative values are positions below horizontal (minimum: -40). Updated at Control-rate. [Default Value: 0]
- (void)setOptionalElevation:(AKParameter *)elevation;



@end
NS_ASSUME_NONNULL_END
