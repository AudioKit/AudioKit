//
//  AKDCBlock.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A DC blocking filter.

 {"Implements the DC blocking filter"=>"Y[i] = X[i] - X[i-1] + (igain * Y[i-1])  Based on work by Perry Cook."}
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKDCBlock : AKAudio
/// Instantiates the dc block with all values
/// @param input Input audio signal. 
/// @param gain The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
- (instancetype)initWithInput:(AKParameter *)input
                         gain:(AKConstant *)gain;

/// Instantiates the dc block with default values
/// @param input Input audio signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the dc block with default values
/// @param input Input audio signal.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
@property (nonatomic) AKConstant *gain;

/// Set an optional gain
/// @param gain The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
- (void)setOptionalGain:(AKConstant *)gain;



@end
NS_ASSUME_NONNULL_END
