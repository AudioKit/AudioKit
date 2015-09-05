//
//  main.m
//  InitialProofOfConcept
//
//  Created by Aurelius Prochazka on 9/4/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#include "soundpipe.h"
#import "AKFMOscillator.h"
#import "AKManager.h"
#import "AKParameter.h"

typedef struct AudioKit {
    AudioUnit outputUnit;
} AudioKit;

OSStatus RenderProc(void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp *inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList * ioData);
void CreateAndConnectOutputUnit(AudioKit *engine) ;

#pragma mark - callback function -
OSStatus RenderProc(void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp *inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList * ioData)
{
    AudioKit *engine = (AudioKit *)inRefCon;
    
    int frame = 0;
    
    for (frame = 0; frame < inNumberFrames; ++frame)
    {
        Float32 outputSignal = 0;
        
        NSMutableArray *operations = [[[AKManager sharedManager] instrument] operations];
        for (AKParameter *operation in operations) {
            if ([operations lastObject] == operation) {
                outputSignal =[operation compute];
            } else {
                [operation compute];
            }
        }
        
        Float32 *data = (Float32*)ioData->mBuffers[0].mData;
        (data)[frame] = outputSignal;
        // copy to right channel too
        data = (Float32*)ioData->mBuffers[1].mData;
        (data)[frame] = outputSignal;
        
    }
    return noErr;
}

#pragma mark - utility functions -

// generic error handler - if err is nonzero, prints error message and exits program.
static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}


void CreateAndConnectOutputUnit (AudioKit *engine) {
    
    //  10.6 and later: generate description that will match out output device (speakers)
    AudioComponentDescription outputcd = {0}; // 10.6 version
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent comp = AudioComponentFindNext (NULL, &outputcd);
    if (comp == NULL) {
        printf ("can't get output unit");
        exit (-1);
    }
    CheckError (AudioComponentInstanceNew(comp, &engine->outputUnit),
                "Couldn't open component for outputUnit");
    
    // register render callback
    AURenderCallbackStruct input;
    input.inputProc = RenderProc;
    input.inputProcRefCon = engine;
    CheckError(AudioUnitSetProperty(engine->outputUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");
    
    // initialize unit
    CheckError (AudioUnitInitialize(engine->outputUnit),
                "Couldn't initialize output unit");
    
}

#pragma mark main

int	main(int argc, const char *argv[])
{
    AudioKit engine = {0};
    
    // set up unit and callback
    CreateAndConnectOutputUnit(&engine);
    
    // start playing
    CheckError (AudioOutputUnitStart(engine.outputUnit), "Couldn't start output unit");
    
    printf ("playing\n");
    // play for 50 seconds
    sleep(50);
    
cleanup:
    AudioOutputUnitStop(engine.outputUnit);
    AudioUnitUninitialize(engine.outputUnit);
    AudioComponentInstanceDispose(engine.outputUnit);
    return 0;
}
