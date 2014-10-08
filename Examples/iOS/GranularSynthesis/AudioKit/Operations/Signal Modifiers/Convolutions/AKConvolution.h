//
//  AKConvolution.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/**  Convolution based on a uniformly partitioned overlap-save algorithm.
 */

@interface AKConvolution : AKAudio

/// Create a convolution
/// @param audioSource             Audio input to the convolution
/// @param impulseResponseFilename Impulse response file. Multichannel files are supported, the file must have the same sample-rate as the orchestra.  Keep in mind that longer files require more calculation time [and probably larger partition sizes and more latency]. At current processor speeds, files longer than a few seconds may not render in real-time.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                impulseResponseFile:(NSString *)impulseResponseFilename;
@end
