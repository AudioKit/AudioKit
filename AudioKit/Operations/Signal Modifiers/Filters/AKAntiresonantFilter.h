//
//  AKAntiresonantFilter.h
//  AudioKit
//
//  Auto-generated on 8/16/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A notch filter whose transfer functions are the complements of AKResonantFilter.
 
 This is a filter whose transfer functions is the complement of AKResonantFilter. Thus AKAntiresonantFilter is a notch filter whose transfer functions represents the “filtered out” aspects of their complements. However, power scaling is not normalized in AKAntiresonantFilter but remains the true complement of the corresponding unit. Thus an audio signal, filtered by parallel matching AKResonantFilter and AKAntiresonantFilter units, would under addition simply reconstruct the original spectrum.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKAntiresonantFilter : AKAudio
/// Instantiates the antiresonant filter with all values
/// @param audioSource The input audio stream. [Default Value: ]
/// @param centerFrequency The center frequency of the filter, or frequency position of the peak response. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth The bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (instancetype)initWithInput:(AKParameter *)audioSource
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth;

/// Instantiates the antiresonant filter with default values
/// @param audioSource The input audio stream.
- (instancetype)initWithInput:(AKParameter *)audioSource;

/// Instantiates the antiresonant filter with default values
/// @param audioSource The input audio stream.
+ (instancetype)filterWithInput:(AKParameter *)audioSource;

/// The center frequency of the filter, or frequency position of the peak response. [Default Value: 1000]
@property (nonatomic) AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency The center frequency of the filter, or frequency position of the peak response. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// The bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth The bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
NS_ASSUME_NONNULL_END
