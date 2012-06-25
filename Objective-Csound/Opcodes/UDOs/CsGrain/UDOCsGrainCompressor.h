//
//  UDOCompressor.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSUserDefinedOpcode.h"

/** Stereo compressor from Boulanger Labs' csGrain application.  
  Stereo audio input and output.  
 */

@interface UDOCsGrainCompressor : OCSUserDefinedOpcode 

/** Left channel output. */
@property (nonatomic, strong) OCSParam *outputLeft;

/** Right channel output. */
@property (nonatomic, strong) OCSParam *outputRight;

/** Instantiates the compressor
 
 @param leftInput Input to the left channel.
 
 @param rightInput Input to the right channel.
 
 @param dBThreshold The lowest decibel level that will be allowed through. 
 Normally 0 or less, but if higher the threshold will begin removing low-level signal energy such as background noise.
 
 @param compressionRatio The ratio of compression when the signal level is above the knee. 
 The value 2 will advance the output just one decibel for every input gain of two; 
 3 will advance just one in three; 20 just one in twenty, etc. 
 Inverse ratios will cause signal expansion: .5 gives two for one, .25 four for one, etc. 
 The value 1 will result in no change.
 
 @param attackTimeInSeconds The attack time in seconds.  Typical value is 0.01.
 
 @param releaseTimeInSeconds The release time in seconds.  Typical value is .1.
*/
- (id)initWithInputLeft:(OCSParam *)leftInput
             InputRight:(OCSParam *)rightInput
            ThresholdDB:(OCSParamControl *)dBThreshold
                  Ratio:(OCSParamControl *)compressionRatio
             AttackTime:(OCSParamControl *)attackTimeInSeconds
            ReleaseTime:(OCSParamControl *)releaseTimeInSeconds;
@end
