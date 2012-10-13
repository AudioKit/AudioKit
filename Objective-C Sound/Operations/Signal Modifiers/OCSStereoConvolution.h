//
//  OCSStereoConvolution.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"
#import "OCSParameter+Operation.h"

/**  Convolution based on a uniformly partitioned overlap-save algorithm.
 
 */
@interface OCSStereoConvolution : OCSStereoAudio

/// Create a convolution
/// @param inputAudio              Audio input to the convolution
/// @param impulseResponseFilename Impulse response file. Multichannel files are supported, the file must have the same sample-rate as the orchestra.  Keep in mind that longer files require more calculation time [and probably larger partition sizes and more latency]. At current processor speeds, files longer than a few seconds may not render in real-time.
- (id)initWithInputAudio:(OCSParameter *)inputAudio
     impulseResponseFile:(NSString *)impulseResponseFilename;
@end
