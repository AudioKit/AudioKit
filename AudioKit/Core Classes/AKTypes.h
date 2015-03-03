//
//  AKTypes.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

#ifndef AKTypes_h
#define AKTypes_h

/// Window types for converting audio into the frequency domain
typedef NS_OPTIONS(NSUInteger, AKFFTWindowType)
{
    AKFFTWindowTypeHamming = 0,
    AKFFTWindowTypeVonHann = 1,
    
};

/// Formant retain methods when scaling in the frequency domain
typedef NS_OPTIONS(NSUInteger, AKScaledFFTFormantRetainMethod)
{
    AKScaledFFTFormantRetainMethodNone = 0,
    AKScaledFFTFormantRetainMethodLifteredCepstrum = 1,
    AKScaledFFTFormantRetainMethodTrueEnvelope = 2,
};



/// MIDI note on/off, control and system exclusive constants
typedef NS_OPTIONS(NSUInteger, AKMidiConstant)
{
    AKMidiConstantNoteOff = 8,
    AKMidiConstantNoteOn = 9,
    AKMidiConstantPolyphonicAftertouch = 10,
    AKMidiConstantControllerChange = 11,
    AKMidiConstantProgramChange = 12,
    AKMidiConstantAftertouch = 13,
    AKMidiConstantPitchWheel = 14,
    AKMidiConstantSysex = 240
};


#endif
