//
//  AKStringResonator.h
//  AudioKit
//
//  Auto-generated on 3/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A string resonator with variable fundamental frequency.

 AKStringResonator passes the input asig through a network composed of comb, low-pass and all-pass filters, similar to the one used in some versions of the Karplus-Strong algorithm, creating a string resonator effect. The fundamental frequency of the “string” is controlled by the fundamentalFrequency.  This operation can be used to simulate sympathetic resonances to an input signal.
 */

@interface AKStringResonator : AKAudio
/// Instantiates the string resonator with all values
/// @param input The input audio signal. [Default Value: ]
/// @param fundamentalFrequency The fundamental frequency of the string. Updated at Control-rate. [Default Value: 100]
/// @param fdbgain feedback gain, between 0 and 1, of the internal delay line. A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. [Default Value: 0.95]
- (instancetype)initWithInput:(AKParameter *)input
         fundamentalFrequency:(AKParameter *)fundamentalFrequency
                      fdbgain:(AKConstant *)fdbgain;

/// Instantiates the string resonator with default values
/// @param input The input audio signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the string resonator with default values
/// @param input The input audio signal.
+ (instancetype)WithInput:(AKParameter *)input;

/// The fundamental frequency of the string. [Default Value: 100]
@property (nonatomic) AKParameter *fundamentalFrequency;

/// Set an optional fundamental frequency
/// @param fundamentalFrequency The fundamental frequency of the string. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency;

/// feedback gain, between 0 and 1, of the internal delay line. A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. [Default Value: 0.95]
@property (nonatomic) AKConstant *fdbgain;

/// Set an optional fdbgain
/// @param fdbgain feedback gain, between 0 and 1, of the internal delay line. A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. [Default Value: 0.95]
- (void)setOptionalFdbgain:(AKConstant *)fdbgain;



@end
