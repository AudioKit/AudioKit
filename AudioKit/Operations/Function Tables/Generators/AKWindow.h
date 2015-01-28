//
//  AKWindow.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFunctionTable.h"

@interface AKWindow : AKFunctionTable

/// Create a window function table
/// @param windowType Type of window to create.
- (instancetype)initWithType:(AKWindowTableType)windowType;

/// Set an optional maximum value of the function table.
@property (nonatomic) float maximum;

/// Set an optional maximum value of the function table.
/// @param maximum The peak value of the function table. [Default: 1]
- (void)setOptionalMaximum:(float)maximum;

/// The openness of a Kaiser Window [Default: 1]
@property (nonatomic) float kaiserOpenness;

/// Set the openness of a Kaiser Window
/// @param kaiserOpenness The openness specifies how "open" the window is, for example a value of 0 results in a rectangular window and a value of 10 in a Hamming like window. [Default: 1]
- (void)setOptionalKaiserWindowOpenness:(float)kaiserOpenness;

/// Width of a Gaussian Window
@property (nonatomic) float standardDeviation;

/// Set the width of a Gaussian Window
/// @param standardDeviation Standard deviation sets the width of the window for Gaussian windows only.  [Default: 1]
- (void)setOptionalGaussianWindowStandardDeviation:(float)standardDeviation;



@end
