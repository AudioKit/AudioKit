//
//  AKWindowTableGenerator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTableGenerator.h"


/// Tables for different window shapes. These windows are usually used for spectrum analysis or for grain envelopes.
@interface AKWindowTableGenerator : AKTableGenerator

// Create Hamming Window
- (instancetype)initHammingWindow;

// Create Hamming Window
+ (instancetype)hammingWindow;


/// Create Hann Window
- (instancetype)initHannWindow;

/// Create Hann Window
+ (instancetype)hannWindow;

/// Create Bartlett (triangle) Window
- (instancetype)initBartlettTriangleWindow;

/// Create Bartlett (triangle) Window
+ (instancetype)bartlettTriangleWindow;

/// Create Blackman (3-term) Window
- (instancetype)initBlackmanThreeTermWindow;

/// Create Blackman (3-term) Window
+ (instancetype)blackmanThreeTermWindow;

/// Create Blackman-Harris (4-term) Window
- (instancetype)initBlackmanHarrisFourTermWindow;

/// Create Blackman-Harris (4-term) Window
+ (instancetype)blackmanHarrisFourTermWindow;

/// Create Gaussian Window
- (instancetype)initGaussianWindow;

/// Create Gaussian Window
+ (instancetype)gaussianWindow;

/// Create Gaussian Window
/// @param standardDeviation Standard deviation sets the width of the window for Gaussian windows.  (Default: 1)
- (instancetype)initGaussianWindowWithStandardDeviation:(float)standardDeviation;

/// Create Gaussian Window
/// @param standardDeviation Standard deviation sets the width of the window for Gaussian windows.  (Default: 1)
+ (instancetype)gaussianWindowWithStandardDeviation:(float)standardDeviation;

/// Create Kaiser Window
- (instancetype)initKaiserWindow;

/// Create Kaiser Window
+ (instancetype)kaiserWindow;

/// Create Kaiser Window
/// @param openness The openness specifies how "open" the window is, for example a value of 0 results in a rectangular window and a value of 10 in a Hamming like window. (Default: 1)
- (instancetype)initKaiserWindowWithOpenness:(float)openness;

/// Create Kaiser Window
/// @param openness The openness specifies how "open" the window is, for example a value of 0 results in a rectangular window and a value of 10 in a Hamming like window. (Default: 1)
+ (instancetype)kaiserWindowWithOpenness:(float)openness;

/// Create Rectangle Window
- (instancetype)initRectangleWindow;

/// Create Rectangle Window
+ (instancetype)rectangleWindow;

/// Create Sync Window
- (instancetype)initSyncWindow;

/// Create Sync Window
+ (instancetype)syncWindow;


@end
