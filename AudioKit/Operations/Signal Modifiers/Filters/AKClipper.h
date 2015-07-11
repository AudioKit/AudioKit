//
//  AKClipper.h
//  AudioKit
//
//  Auto-generated on 7/10/15. (Motivated by Daniel Clelland)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Clips a signal to a predefined limit, in a "soft" manner, using one of three methods.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKClipper : AKAudio

//Type Helpers

/// Default Bram de Jong method
+ (AKConstant *)clippingMethodBramDeJong;

/// Sine clipper
+ (AKConstant *)clippingMethodSine;

/// Tanh clipper method
+ (AKConstant *)clippingMethodTanh;


/// Instantiates the clipper with all values
/// @param input Input signal [Default Value: ]
/// @param limit The limiting value. [Default Value: 1]
/// @param method Clipping method Bram de Jong (default), sine, or tanh. [Default Value: AKClipperMethodBramDeJong]
/// @param clippingStartPoint Where to start clipping in the Bram de Jong method only (0-1). [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
                        limit:(AKConstant *)limit
                       method:(AKConstant *)method
           clippingStartPoint:(AKConstant *)clippingStartPoint;

/// Instantiates the clipper with default values
/// @param input Input signal
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the clipper with default values
/// @param input Input signal
+ (instancetype)clipperWithInput:(AKParameter *)input;

/// The limiting value. [Default Value: 1]
@property (nonatomic) AKConstant *limit;

/// Set an optional limit
/// @param limit The limiting value. [Default Value: 1]
- (void)setOptionalLimit:(AKConstant *)limit;

/// Clipping method Bram de Jong (default), sine, or tanh. [Default Value: AKClipperMethodBramDeJong]
@property (nonatomic) AKConstant *method;

/// Set an optional method
/// @param method Clipping method Bram de Jong (default), sine, or tanh. [Default Value: AKClipperMethodBramDeJong]
- (void)setOptionalMethod:(AKConstant *)method;

/// Where to start clipping in the Bram de Jong method only. [Default Value: 0.5]
@property (nonatomic) AKConstant *clippingStartPoint;

/// Set an optional clipping start point
/// @param clippingStartPoint Where to start clipping in the Bram de Jong method only (0-1). [Default Value: 0.5]
- (void)setOptionalClippingStartPoint:(AKConstant *)clippingStartPoint;

@end
NS_ASSUME_NONNULL_END

