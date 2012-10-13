//
//  UDOMSROscillator.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Generates indicated wave with amplitude declick ramps of .02 sec on each end.  
 The frequency can be given either as pitch or in Hz, and the type can be
 a sine, triangle, saw, square, tube distortion, half triangle, half square, half-saw, or 
 white noise.
 
 Available Types:
 
 - Sine
 - Triangle
 - Saw
 - Square
 - Tube Distortion
 - Half Triangle
 - Half Square
 - Half Saw
 - White Noise (in this case, frequency has no meaning)
 
*/

typedef enum {
    kMSROscillatorTypeSine,
    kMSROscillatorTypeTriangle,
    kMSROscillatorTypeSaw,
    kMSROscillatorTypeSquare,
    kMSROscillatorTypeTubeDistortion,
    kMSROscillatorTypeHalfTriangle,
    kMSROscillatorTypeHalfSquare,
    kMSROscillatorTypeHalfSaw,
    kMSROscillatorTypeWhiteNoise
} OscillatorType;

@interface UDOMSROscillator : OCSAudio 

/** Instantiates the user-defined opcode for Michael Rempel's Oscillator.
 
 @param maxAmplitude     Maximum output of the signal in relation to the 0dB full scale amplitude. Must be greater than zero.
 @param pitchOrFrequency Pitch is assume if the value is less than 20, otherwise the units are Hz.
 @param oscillatorType   Type of waveform to be used from the available OscillatorTypes.
 @return                 An instance of UDOMSROscillator.
 */
- (id)initWithType:(OscillatorType)oscillatorType
         frequency:(OCSControl *)pitchOrFrequency
         amplitude:(OCSConstant *)maxAmplitude;

- (NSString *) udoFile;

@end
