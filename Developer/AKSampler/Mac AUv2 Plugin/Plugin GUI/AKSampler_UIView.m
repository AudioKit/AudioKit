//
//  AKSampler_UIView.m
//  AKSamplerUI
//
//  Created by Shane Dunne, revision history on Githbub.
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
    { 0, kFilterCutoffEgStrength, kAudioUnitScope_Global, 0 },
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
    
    // initial setup
    [self priv_synchronizeUIWithParameterValues];
}


#pragma mark ____ INTERFACE ACTIONS ____

- (IBAction)onVolumeSlider:(NSSlider *)sender {
    float inValue = [sender floatValue] / 100.0f;
    [volumeText setIntValue: 100 * inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kMasterVolumeFraction], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onVolumeSlider:] AUParameterSet()");
}

- (IBAction)onPitchOffsetSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [pitchOffsetText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kPitchOffsetSemitones], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onPitchOffsetSlider:] AUParameterSet()");
}

- (IBAction)onVibratoDepthSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [vibratoDepthText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kVibratoDepthSemitones], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onVibratoDepthSlider:] AUParameterSet()");
}

- (IBAction)onAmpAttackSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [ampAttackText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kAmpEgAttackTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onAmpAttackSlider:] AUParameterSet()");
}

- (IBAction)onAmpDecaySlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [ampDecayText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kAmpEgDecayTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onAmpDecaySlider:] AUParameterSet()");
}

- (IBAction)onAmpSustainSlider:(NSSlider *)sender {
    float inValue = [sender floatValue] / 100.0f;
    [ampSustainText setFloatValue: 100.0f * inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kAmpEgSustainFraction], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onAmpSustainSlider:] AUParameterSet()");
}

- (IBAction)onAmpReleaseSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [ampReleaseText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kAmpEgReleaseTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onAmpReleaseSlider:] AUParameterSet()");
}

- (IBAction)onFilterEnableCheckbox:(NSButton *)sender {
    bool enable = ([sender state] == NSOnState);
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterEnable], (Float32)(enable ? 1 : 0), 0) == noErr,
             @"[AKSampler_UIView onFilterEnableCheckbox:] AUParameterSet()");
}

- (IBAction)onFilterCutoffSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterCutoffText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterCutoffHarmonic], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterCutoffSlider:] AUParameterSet()");
}

- (IBAction)onFilterEgStrengthSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterEgStrengthText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterCutoffEgStrength], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterEgStrengthSlider:] AUParameterSet()");
}

- (IBAction)onFilterResonanceSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterResonanceText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterResonanceDb], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterResonanceSlider:] AUParameterSet()");
}

- (IBAction)onFilterAttackSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterAttackText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterEgAttackTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterAttackSlider:] AUParameterSet()");
}

- (IBAction)onFilterDecaySlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterDecayText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterEgDecayTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterDecaySlider:] AUParameterSet()");
}

- (IBAction)onFilterSustainSlider:(NSSlider *)sender {
    float inValue = [sender floatValue] / 100.0f;
    [filterSustainText setFloatValue: 100.0f * inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterEgSustainFraction], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterSustainSlider:] AUParameterSet()");
}

- (IBAction)onFilterReleaseSlider:(NSSlider *)sender {
    float inValue = [sender floatValue];
    [filterReleaseText setFloatValue: inValue];
    NSAssert(AUParameterSet(mParameterListener, sender, &parameter[kFilterEgReleaseTimeSeconds], (Float32)inValue, 0) == noErr,
             @"[AKSampler_UIView onFilterReleaseSlider:] AUParameterSet()");
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

- (IBAction)onPresetFolderButton:(NSButton *)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    if ([panel runModal] != NSModalResponseOK) return;
    mPresetFolder = [[panel URLs] lastObject];
    
    // Should I do something here to release the previous copied value?
    CFStringRef cfstr = (__bridge CFStringRef)[[mPresetFolder path] copy];
    UInt32 dataSize = sizeof(CFStringRef);
    ComponentResult result = AudioUnitSetProperty(mAU,
                                                  kPresetFolderPathProperty,
                                                  kAudioUnitScope_Global,
                                                  0,
                                                  (void*)cfstr,
                                                  dataSize);
    if (result != noErr)
        printf("Error %d trying to set preset folder path property", result);

    [self priv_populatePresetPopup];
}

#pragma mark ____ PRIVATE FUNCTIONS ____

- (void)priv_populatePresetPopup
{
    [presetPopup removeAllItems];

    NSArray<NSString *> *allFiles = [[NSFileManager defaultManager]
                                     contentsOfDirectoryAtPath:[mPresetFolder path]
                                     error:nil];
    NSArray<NSString *> *filesSorted = [allFiles sortedArrayUsingSelector:@selector(compare:)];
    for (int i=0; i < [filesSorted count]; i++)
    {
        NSString *fileName = [filesSorted objectAtIndex:i];
        if ([fileName hasSuffix:@".sfz"])
            [presetPopup addItemWithTitle: [fileName stringByReplacingOccurrencesOfString:@".sfz" withString:@""]];
    }
    [presetPopup selectItemAtIndex:-1];
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
        case kPitchOffsetSemitones:
            [pitchOffsetSlider setFloatValue: inValue];
            [pitchOffsetText setFloatValue: inValue];
            break;
        case kVibratoDepthSemitones:
            [vibratoDepthSlider setFloatValue: inValue];
            [vibratoDepthText setFloatValue: inValue];
            break;
        case kAmpEgAttackTimeSeconds:
            [ampAttackSlider setFloatValue: inValue];
            [ampAttackText setFloatValue: inValue];
            break;
        case kAmpEgDecayTimeSeconds:
            [ampDecaySlider setFloatValue: inValue];
            [ampDecayText setFloatValue: inValue];
            break;
        case kAmpEgSustainFraction:
            [ampSustainSlider setFloatValue: 100 * inValue];
            [ampSustainText setFloatValue: 100 * inValue];
            break;
       case kAmpEgReleaseTimeSeconds:
            [ampReleaseSlider setFloatValue: inValue];
            [ampReleaseText setFloatValue: inValue];
            break;
        case kFilterEnable:
            [filterEnableCheckbox setState: inValue != 0.0 ? NSOnState : NSOffState];
            break;
        case kFilterCutoffHarmonic:
            [filterCutoffSlider setFloatValue: inValue];
            [filterCutoffText setFloatValue: inValue];
            break;
        case kFilterCutoffEgStrength:
            [filterEgStrengthSlider setFloatValue: inValue];
            [filterEgStrengthText setFloatValue: inValue];
            break;
        case kFilterResonanceDb:
            [filterResonanceSlider setFloatValue: inValue];
            [filterResonanceText setFloatValue: inValue];
            break;
        case kFilterEgAttackTimeSeconds:
            [filterAttackSlider setFloatValue: inValue];
            [filterAttackText setFloatValue: inValue];
            break;
        case kFilterEgDecayTimeSeconds:
            [filterDecaySlider setFloatValue: inValue];
            [filterDecayText setFloatValue: inValue];
            break;
        case kFilterEgSustainFraction:
            [filterSustainSlider setFloatValue: 100 * inValue];
            [filterSustainText setFloatValue: 100 * inValue];
            break;
        case kFilterEgReleaseTimeSeconds:
            [filterReleaseSlider setFloatValue: inValue];
            [filterReleaseText setFloatValue: inValue];
            break;
    }
}

@end
