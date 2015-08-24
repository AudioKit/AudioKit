//
//  AKDistortion.h
//  AudioKit
//
//  Auto-generated on 7/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Modified hyperbolic tangent distortion

 More detailed description from http://www.csounds.com/manual/html/distort1.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKDistortion : AKAudio
/// Instantiates the distortion with all values
/// @param input Audio input to distort [Default Value: ]
/// @param pregain Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion. Updated at Control-rate. [Default Value: 1]
/// @param postiveShapeParameter Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. Updated at Control-rate. [Default Value: 0]
/// @param negativeShapeParameter Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. Updated at Control-rate. [Default Value: 0]
/// @param postgain Determines the amount of gain applied to the signal after waveshaping. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithInput:(AKParameter *)input
                      pregain:(AKParameter *)pregain
        postiveShapeParameter:(AKParameter *)postiveShapeParameter
       negativeShapeParameter:(AKParameter *)negativeShapeParameter
                     postgain:(AKParameter *)postgain;

/// Instantiates the distortion with default values
/// @param input Audio input to distort
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the distortion with default values
/// @param input Audio input to distort
+ (instancetype)distortionWithInput:(AKParameter *)input;

/// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion. [Default Value: 1]
@property (nonatomic) AKParameter *pregain;

/// Set an optional pregain
/// @param pregain Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalPregain:(AKParameter *)pregain;

/// Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. [Default Value: 0]
@property (nonatomic) AKParameter *postiveShapeParameter;

/// Set an optional postive shape parameter
/// @param postiveShapeParameter Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalPostiveShapeParameter:(AKParameter *)postiveShapeParameter;

/// Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. [Default Value: 0]
@property (nonatomic) AKParameter *negativeShapeParameter;

/// Set an optional negative shape parameter
/// @param negativeShapeParameter Determines the shape of the positive part of the curve. A value of 0 gives a flat clip, small positive values give sloped shaping. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalNegativeShapeParameter:(AKParameter *)negativeShapeParameter;

/// Determines the amount of gain applied to the signal after waveshaping. [Default Value: 1]
@property (nonatomic) AKParameter *postgain;

/// Set an optional postgain
/// @param postgain Determines the amount of gain applied to the signal after waveshaping. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalPostgain:(AKParameter *)postgain;



@end
NS_ASSUME_NONNULL_END

