//
//  AKFlanger_UIView.m
//  AKFlangerUI
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import "AKFlanger_UIView.h"
#include "AKFlanger_Params.h"

#pragma mark ____ LISTENER CALLBACK DISPATCHER ____

AudioUnitParameter parameter[] = {
    { 0, kModFrequency, kAudioUnitScope_Global, 0 },
    { 0, kModDepth, kAudioUnitScope_Global, 0 },
    { 0, kFeedback, kAudioUnitScope_Global, 0 },
    { 0, kDryWetMix, kAudioUnitScope_Global, 0 },
};


void ParameterListenerDispatcher (void *inRefCon, void *inObject, const AudioUnitParameter *inParameter, Float32 inValue) {
    AKFlanger_UIView *SELF = (AKFlanger_UIView *)inRefCon;
    
    [SELF priv_parameterListener:inObject parameter:inParameter value:inValue];
}


@implementation AKFlanger_UIView


#pragma mark ____ (INIT /) DEALLOC ____

- (void)dealloc {
    [self priv_removeListeners];
    [super dealloc];
}


#pragma mark ____ PUBLIC FUNCTIONS ____

- (void)setAU:(AudioUnit)inAU {
    // remove previous listeners
    if (mAU)
        [self priv_removeListeners];
    
    mAU = inAU;
    
    // add new listeners
    [self priv_addListeners];
    
    // initial setup
    [self priv_synchronizeUIWithParameterValues];
}


#pragma mark ____ INTERFACE ACTIONS ____


#pragma mark ____ PRIVATE FUNCTIONS ____

- (void)priv_addListeners
{
    NSAssert (AUListenerCreate(ParameterListenerDispatcher, self,
                               CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 0.100, // 100 ms
                               &mParameterListener ) == noErr,
              @"[CocoaView _addListeners] AUListenerCreate()");
    
    for (int i = 0; i < kNumberOfParams; ++i) {
        parameter[i].mAudioUnit = mAU;
        NSAssert (AUListenerAddParameter (mParameterListener, NULL, &parameter[i]) == noErr,
                  @"[CocoaView _addListeners] AUListenerAddParameter()");
    }
}

- (void)priv_removeListeners
{
    for (int i = 0; i < kNumberOfParams; ++i) {
        NSAssert (AUListenerRemoveParameter(mParameterListener, NULL, &parameter[i]) == noErr,
                  @"[CocoaView _removeListeners] AUListenerRemoveParameter()");
    }
    
    NSAssert (AUListenerDispose(mParameterListener) == noErr,
              @"[CocoaView _removeListeners] AUListenerDispose()");

    mParameterListener = NULL;
    mAU = NULL;
}

- (void)priv_synchronizeUIWithParameterValues
{
    Float32 value;
    for (int i = 0; i < kNumberOfParams; ++i) {
        NSAssert (AudioUnitGetParameter(mAU, parameter[i].mParameterID, kAudioUnitScope_Global, 0, &value) == noErr,
                  @"[CocoaView synchronizeUIWithParameterValues] (x.1)");
        NSAssert (AUParameterSet (mParameterListener, self, &parameter[i], value, 0) == noErr,
                  @"[CocoaView synchronizeUIWithParameterValues] (x.2)");
        NSAssert (AUParameterListenerNotify (mParameterListener, self, &parameter[i]) == noErr,
                  @"[CocoaView synchronizeUIWithParameterValues] (x.3)");
    }
}


#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____

- (void)priv_parameterListener:(void *)inObject parameter:(const AudioUnitParameter *)inParameter value:(Float32)inValue {
    //inObject ignored in this case.
    
    switch (inParameter->mParameterID) {
        case kModFrequency:
            break;
        case kModDepth:
            break;
        case kFeedback:
            break;
        case kDryWetMix:
            break;

    }
}

@end
