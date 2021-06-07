// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if !TARGET_OS_TV
#import <CoreAudioKit/CoreAudioKit.h>
#endif

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

#import "DSPBase.h"

#import "ExceptionCatcher.h"
#import "AUParameterTreeExt.h"

// Testing
#import "DebugDSP.h"

// Sequencing / MIDI
#import "SequencerEngine.h"

// Automation
#import "ParameterRamper.h"
#import "ParameterAutomation.h"

// Swift/ObjC/C/C++ Inter-operability
#import "Interop.h"

typedef void (^CMIDICallback)(uint8_t, uint8_t, uint8_t);
AK_API void akCallbackInstrumentSetCallback(DSPRef dsp, CMIDICallback callback);

// Misc
#import "BufferedAudioBus.h"
