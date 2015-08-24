//
//  AKRingModulator.h
//  AudioKit
//
//  Auto-generated on 4/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Julian Parker Ring Modulator

 {"This is the Julian Parker Ring Modulator digital model described here"=>"http://kunstmusik.com/2013/09/07/julian-parker-ring-modulator/"}
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKRingModulator : AKAudio
/// Instantiates the ring modulator with all values
/// @param input Input audio signal
/// @param carrier The carrier signal 
- (instancetype)initWithInput:(AKParameter *)input
                      carrier:(AKParameter *)carrier;

/// Instantiates the ring modulator with default values
/// @param input Input audio signal
/// @param carrier The carrier signal
+ (instancetype)modulationWithInput:(AKParameter *)input
                            carrier:(AKParameter *)carrier;



@end
NS_ASSUME_NONNULL_END
