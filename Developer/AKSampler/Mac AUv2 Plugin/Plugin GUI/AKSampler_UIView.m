//
//  AKSampler_UIView.m
//  AKSamplerUI
//
//  Created by Shane Dunne on 2018-03-02.
//

#import "AKSampler_UIView.h"
#include "AKSampler_Params.h"

#pragma mark ____ LISTENER CALLBACK DISPATCHER ____

AudioUnitParameter parameter[] = {
    { 0, kMasterVolumeFraction, kAudioUnitScope_Global, 0 },
    { 0, kPitchOffsetSemitones, kAudioUnitScope_Global, 0 },
    { 0, kVibratoDepthSemitones, kAudioUnitScope_Global, 0 },
    { 0, kFilterEnable, kAudioUnitScope_Global, 0 },
    { 0, kFilterCutoffHarmonic, kAudioUnitScope_Global, 0 },
    { 0, kFilterResonanceDb, kAudioUnitScope_Global, 0 },
    { 0, kAmpEgAttackTimeSeconds, kAudioUnitScope_Global, 0 },
    { 0, kAmpEgDecayTimeSeconds, kAudioUnitScope_Global, 0 },
    { 0, kAmpEgSustainFraction, kAudioUnitScope_Global, 0 },
    { 0, kAmpEgReleaseTimeSeconds, kAudioUnitScope_Global, 0 },
    { 0, kFilterEgAttackTimeSeconds, kAudioUnitScope_Global, 0 },
    { 0, kFilterEgDecayTimeSeconds, kAudioUnitScope_Global, 0 },
    { 0, kFilterEgSustainFraction, kAudioUnitScope_Global, 0 },
    { 0, kFilterEgReleaseTimeSeconds, kAudioUnitScope_Global, 0 },
};


void ParameterListenerDispatcher (void *inRefCon, void *inObject, const AudioUnitParameter *inParameter, Float32 inValue) {
    AKSampler_UIView *SELF = (AKSampler_UIView *)inRefCon;
    
    [SELF priv_parameterListener:inObject parameter:inParameter value:inValue];
}


@implementation AKSampler_UIView


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
    
    // populate preset popup
    [self priv_populatePresetPopup];
    
    // initial setup
    [self priv_synchronizeUIWithParameterValues];
}


#pragma mark ____ INTERFACE ACTIONS ____

- (IBAction)onVolumeSlider:(id)sender {
    float floatValue = [volumeSlider floatValue] / 100.0f;
    [volumeText setIntValue: 100 * floatValue];

    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kMasterVolumeFraction], (Float32)floatValue, 0) == noErr,
             @"[AKSampler_UIView onVolumeSlider:] AUParameterSet()");
}

- (IBAction)onPresetSelect:(NSPopUpButton *)sender {
    CFStringRef cfstr = (__bridge CFStringRef)[presetPopup titleOfSelectedItem];
    
    UInt32 dataSize = sizeof(CFStringRef);
    ComponentResult result = AudioUnitSetProperty(mAU,
                                                  kPresetNameProperty,
                                                  kAudioUnitScope_Global,
                                                  0,
                                                  (void*)cfstr,
                                                  dataSize);
    if (result != noErr)
        printf("Error %d trying to set preset name property", result);
}


#pragma mark ____ PRIVATE FUNCTIONS ____

- (void)priv_populatePresetPopup
{
    [presetPopup removeAllItems];

    NSArray<NSString *> *allFiles = [[NSFileManager defaultManager]
                                     contentsOfDirectoryAtPath:@PRESETS_DIR_PATH
                                     error:nil];
    for (int i=0; i < [allFiles count]; i++)
    {
        NSString *fileName = [allFiles objectAtIndex:i];
        if ([fileName hasSuffix:@".sfz"])
            [presetPopup addItemWithTitle: [fileName stringByReplacingOccurrencesOfString:@".sfz" withString:@""]];
    }
}

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
        case kMasterVolumeFraction:
            [volumeSlider setFloatValue: 100 * inValue];
            [volumeText setIntValue: 100 * inValue];
            break;
            
    }
}

@end
