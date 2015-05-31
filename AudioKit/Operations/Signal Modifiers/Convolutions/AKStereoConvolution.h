//
//  AKStereoConvolution.h
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Customized by Aurelius Prochazka to simplify the interface.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Convolution based on a uniformly partitioned overlap-save algorithm.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKStereoConvolution : AKStereoAudio
/// Instantiates the stereo convolution with all values
/// @param input Input to the convolution, usually audio.
/// @param impulseResponseFilename File contain the impulse response audio.  Usually a very short impulse sound.
- (instancetype)initWithInput:(AKParameter *)input
      impulseResponseFilename:(NSString *)impulseResponseFilename;

/// Instantiates the stereo convolution with default values
/// @param input Input to the convolution, usually audio.
/// @param impulseResponseFilename File contain the impulse response audio.  Usually a very short impulse sound.
+ (instancetype)convolutionWithInput:(AKParameter *)input
             impulseResponseFilename:(NSString *)impulseResponseFilename;



@end
NS_ASSUME_NONNULL_END
