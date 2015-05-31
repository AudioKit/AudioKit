//
//  AKFFTProcessor.h
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Phase vocoder analysis processing with onset detection/processing.

 This operation allows for time and frequency-independent scaling. Time is advanced internally, but controlled by a tempo scaling parameter; when an onset is detected, timescaling is momentarily stopped to avoid smearing of attacks. The quality of the effect is generally improved with phase locking switched on.
 This operation will also scale pitch, independently of frequency, using a transposition factor.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFFTProcessor : AKFSignal
/// Instantiates the fft processor with all values
/// @param table Primary input is a table, usually a mono sound file. Updated at Control-rate. 
/// @param frequencyRatio Grain frequency scaling (1=normal pitch, < 1 lower, > 1 higher; negative, backwards) Updated at Control-rate. [Default Value: 1]
/// @param timeRatio Time Scaling ratio, < 1 stretches, > 1 contracts. Updated at Control-rate. [Default Value: 1]
/// @param amplitude Amplitude of the output. Updated at Control-rate. [Default Value: 1]
/// @param tableOffset Startup read offset into table, in seconds. [Default Value: 0]
/// @param sizeOfFFT FFT size- must be a factor of 2. [Default Value: 2048]
/// @param hopSize Size of hop [Default Value: 512]
/// @param dbthresh Threshold for onset detection, based on dB power spectrum ratio between two successive windows. A detected ratio above it will cancel timescaling momentarily, to avoid smearing (defaults to 1). By default anything more than a 1 dB inter-frame power difference will be detected as an onset. [Default Value: 1]
- (instancetype)initWithTable:(AKParameter *)table
               frequencyRatio:(AKParameter *)frequencyRatio
                    timeRatio:(AKParameter *)timeRatio
                    amplitude:(AKParameter *)amplitude
                  tableOffset:(AKConstant *)tableOffset
                    sizeOfFFT:(AKConstant *)sizeOfFFT
                      hopSize:(AKConstant *)hopSize
                     dbthresh:(AKConstant *)dbthresh;

/// Instantiates the fft processor with default values
/// @param table Primary input is a table, usually a mono sound file.
- (instancetype)initWithTable:(AKParameter *)table;

/// Instantiates the fft processor with default values
/// @param table Primary input is a table, usually a mono sound file.
+ (instancetype)WithTable:(AKParameter *)table;

/// Grain frequency scaling (1=normal pitch, < 1 lower, > 1 higher; negative, backwards) [Default Value: 1]
@property (nonatomic) AKParameter *frequencyRatio;

/// Set an optional frequency ratio
/// @param frequencyRatio Grain frequency scaling (1=normal pitch, < 1 lower, > 1 higher; negative, backwards) Updated at Control-rate. [Default Value: 1]
- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio;

/// Time Scaling ratio, < 1 stretches, > 1 contracts. [Default Value: 1]
@property (nonatomic) AKParameter *timeRatio;

/// Set an optional time ratio
/// @param timeRatio Time Scaling ratio, < 1 stretches, > 1 contracts. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalTimeRatio:(AKParameter *)timeRatio;

/// Amplitude of the output. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the output. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Startup read offset into table, in seconds. [Default Value: 0]
@property (nonatomic) AKConstant *tableOffset;

/// Set an optional table offset
/// @param tableOffset Startup read offset into table, in seconds. [Default Value: 0]
- (void)setOptionalTableOffset:(AKConstant *)tableOffset;

/// FFT size- must be a factor of 2. [Default Value: 2048]
@property (nonatomic) AKConstant *sizeOfFFT;

/// Set an optional size of fft
/// @param sizeOfFFT FFT size- must be a factor of 2. [Default Value: 2048]
- (void)setOptionalSizeOfFFT:(AKConstant *)sizeOfFFT;

/// Size of hop [Default Value: 512]
@property (nonatomic) AKConstant *hopSize;

/// Set an optional hop size
/// @param hopSize Size of hop [Default Value: 512]
- (void)setOptionalHopSize:(AKConstant *)hopSize;

/// Threshold for onset detection, based on dB power spectrum ratio between two successive windows. A detected ratio above it will cancel timescaling momentarily, to avoid smearing (defaults to 1). By default anything more than a 1 dB inter-frame power difference will be detected as an onset. [Default Value: 1]
@property (nonatomic) AKConstant *dbthresh;

/// Set an optional dbthresh
/// @param dbthresh Threshold for onset detection, based on dB power spectrum ratio between two successive windows. A detected ratio above it will cancel timescaling momentarily, to avoid smearing (defaults to 1). By default anything more than a 1 dB inter-frame power difference will be detected as an onset. [Default Value: 1]
- (void)setOptionalDbthresh:(AKConstant *)dbthresh;



@end
NS_ASSUME_NONNULL_END
