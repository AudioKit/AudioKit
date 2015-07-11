//
//  AKClip.h
//  AudioKit
//
//  Created by Daniel Clelland on 11/07/15.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

typedef NS_ENUM(NSUInteger, AKClipClippingMethod) {
    AKClipClippingMethodBramDeJong = 0,
    AKClipClippingMethodSine,
    AKClipClippingMethodTanh
};

/** Clip effect
 
 Clips a signal to a predefined limit, in a "soft" manner, using one of three methods.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKClip : AKAudio
/// Instantiates the clipper with all values
/// @param input Input signal. [Default Value: ]
/// @param clippingMethod The method used to apply the clip. Should use the AKClipClippingMethod enum. [Default Value: AKClipClippingMethodBramDeJong]
/// @param limit The limiting value. [Default Value: 1.0]
/// @param argument The argument to the Bram de Jong function. Indicates the point at which clipping starts, in the range 0 - 1. Not used with the other clipping methods. [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
               clippingMethod:(AKConstant *)clippingMethod
                        limit:(AKConstant *)limit
                     argument:(AKConstant *)argument;

/// Instantiates the clipper with default values
/// @param input Input signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the clipper with default values
/// @param input Input signal.
+ (instancetype)effectWithInput:(AKParameter *)input;

@end
NS_ASSUME_NONNULL_END
