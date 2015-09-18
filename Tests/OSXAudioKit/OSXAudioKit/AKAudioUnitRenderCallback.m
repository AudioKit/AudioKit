//
//  AKAudioUnitRenderCallback.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#include <OSXAudioKit-Swift.h>
#include "AKAudioUnitRenderCallback.h"

OSStatus AudioUnitRenderCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData)
{
    return [[AKManager sharedManager] render:ioActionFlags
                                   timeStamp:inTimeStamp
                                   busNumber:inBusNumber
                                  frameCount:inNumberFrames
                                        data:ioData];
}

AURenderCallback audioKitAudioUnitRenderCallback_ptr()
{
    return AudioUnitRenderCallback;
}
