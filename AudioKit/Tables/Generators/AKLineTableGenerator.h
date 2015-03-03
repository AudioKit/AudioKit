//
//  AKLineTableGenerator/h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKTableGenerator.h"

/** Construct functions from segments of straight lines
*/
@interface AKLineTableGenerator : AKTableGenerator

/// Creates a square waveform with a default size of 4096.
- (instancetype)initSquareWave;

/// Creates a square waveform with a default size of 4096.
+ (instancetype)squareWave;

/// Creates a triangle waveform with a default size of 4096.
- (instancetype)initTriangleWave;

/// Creates a triangle waveform with a default size of 4096.
+ (instancetype)triangleWave;

/// Creates a sawtooth waveform with a default size of 4096.
- (instancetype)initSawtoothWave;

/// Creates a sawtooth waveform with a default size of 4096.
+ (instancetype)sawtoothWave;

/// Creates a reverse sawtooth waveform with a default size of 4096.
- (instancetype)initReverseSawtoothWave;

/// Creates a reverse sawtooth waveform with a default size of 4096.
+ (instancetype)reverseSawtoothWave;

/// Start the line segments at a specific value
/// @param value Initial value of the the first line segment
- (instancetype)initWithValue:(float)value;

/// Add a junction point
/// @param value The value at the given index
/// @param index The index at which the value will be set
- (void)addValue:(float)value atIndex:(int)index;

/// Add a junction point
/// @param value The value at the given index
/// @param numberOfElements The index at which the value will be set
- (void)appendValue:(float)value afterNumberOfElements:(int)numberOfElements;

@end
