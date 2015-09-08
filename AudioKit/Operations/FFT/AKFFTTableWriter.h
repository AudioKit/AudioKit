//
//  AKFFTTableWriter.h
//  AudioKit
//
//  Auto-generated on 9/5/15.
//  Customised by Daniel Clelland on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Writes amplitude and/or frequency data to function tables.

 More detailed description from http://www.csounds.com/manual/html/pvsftw.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFFTTableWriter : AKControl
/// Instantiates the fft table writer with all values
/// @param input An AKFsignal which the table is read from. [Default Value: ]
/// @param amplitudeTable A table, at least inbins in size, that stores amplitude data. [Default Value: ]
/// @param frequencyTable A table, at least inbins in size, that stores amplitude data. [Default Value: ]
- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable
               frequencyTable:(AKTable *)frequencyTable;

/// Instantiates the fft table writer with default values
/// @param input An AKFsignal which the table is read from.
/// @param amplitudeTable A table, at least inbins in size, that stores amplitude data.
- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable;

/// Instantiates the fft table writer with default values
/// @param input An AKFsignal which the table is read from.
/// @param amplitudeTable A table, at least inbins in size, that stores amplitude data.
+ (instancetype)fftTableWriterWithInput:(AKFSignal *)input
                         amplitudeTable:(AKTable *)amplitudeTable;

/// A table, at least inbins in size, that stores amplitude data. [Default Value: ]
@property (nonatomic) AKTable *frequencyTable;

/// Set an optional frequency table
/// @param frequencyTable A table, at least inbins in size, that stores amplitude data. [Default Value: ]
- (void)setOptionalFrequencyTable:(AKTable *)frequencyTable;



@end
NS_ASSUME_NONNULL_END

