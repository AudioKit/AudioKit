//
//  OCSWindowsTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"

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
 
 @warning *Not Fully Supported Functions* 
 
 Currently, when defining maximumValue, we automatically negate the Gen Type, 
 but this is description from the Csound manual:
 
 `maximumValue` -- For negative p4 this will be the absolute value at window peak point. 
 If p4 is positive or p4 is negative and p6 is missing the table will be 
 post-rescaled to a maximum value of 1.
 
 @warning *Unsupported Functions* 
 
 `opt` -- Optional argument required by the Gaussian window and the Kaiser window.
 */
@interface OCSWindowsTable : OCSFunctionTable

typedef enum
{
    kWindowHamming=1,
    kWindowHanning=2,
    kWindowBartlettTriangle=3,
    kWindowBlackmanThreeTerm=4,
    kWindowBlackmanHarrisFourTerm=5,
    kWindowGaussian=6,
    kWindowKaiser=7,
    KWindowRectangle=8,
    kWindowSync=9
} WindowType;

/// Instantiates the window function table.
/// @param tableSize    Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param windowType   Type of window to generate.
/// @param maximumValue Absolute value at window peak point. 
- (id)initWithSize:(int)tableSize 
        WindowType:(WindowType)windowType 
          MaxValue:(int)maximumValue;

/// Instantiates the window function table.
/// @param tableSize    Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param windowType   Type of window to generate.
- (id)initWithSize:(int)tableSize WindowType:(WindowType)windowType;

@end
