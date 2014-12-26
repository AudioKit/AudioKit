//
//  AKWindowsTable.h
//  AudioKit
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "AKFunctionTable.h"
#import "AKTypes.h"

/** Generates functions of different windows. These windows are usually used for
 spectrum analysis or for grain envelopes.
 
 Window Types supported are:
 
 1. Hamming
 2. Hanning
 3. Bartlett (triangle)
 4. Blackman (3-term)
 5. Blackman - Harris (4-term)
 6. Gaussian
 7. Kaiser
 8. Rectangle
 9. Sync
 
 */
@interface AKWindowsTable : AKFunctionTable

/// Instantiates the window function table.
/// @param windowType Type of window to generate.
/// @param maximum    Absolute value at window peak point.
/// @param tableSize  Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
- (instancetype)initWithType:(AKWindowTableType)windowType
                     maximum:(float)maximum
                        size:(int)tableSize;

/// Instantiates the window function table with a maximum value of 1.
/// @param windowType   Type of window to generate.
/// @param tableSize    Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
- (instancetype)initWithType:(AKWindowTableType)windowType
                        size:(int)tableSize;

/// Creates a Gaussian Windown Function Table
/// @param windowBroadness Specifies how broad the window is, as the standard deviation of the curve; in this example the s.d. is 2. The default value is 1.
/// @param maximum    Absolute value at window peak point.
/// @param tableSize  Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
- (instancetype)initGaussianTypeWithBroadness:(float)windowBroadness
                                      maximum:(float)maximum
                                         size:(int)tableSize;

/// Creates a Kaiser Windown Function Table
/// @param windowOpenness Specifies how "open" the window is, for example a value of 0 results in a rectangular window and a value of 10 in a Hamming like window.
/// @param maximum        Absolute value at window peak point.
/// @param tableSize      Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
- (instancetype)initKaiserTypeWithOpenness:(float)windowOpenness
                                   maximum:(float)maximum
                                      size:(int)tableSize;

@end
