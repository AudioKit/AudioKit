//
//  AKAudioUnitRenderCallback.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <AudioUnit/AudioUnit.h>

OSStatus AudioUnitRenderCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData);

AURenderCallback audioKitAudioUnitRenderCallback_ptr();
