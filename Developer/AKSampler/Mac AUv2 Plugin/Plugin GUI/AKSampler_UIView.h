//
//  AKSampler_UIView.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AKSampler_UIView : NSView
{
    // IBOutlets
    IBOutlet NSSlider *volumeSlider;
    IBOutlet NSTextField *volumeText;
    IBOutlet NSPopUpButton *presetPopup;
    
    // Other Members
    AudioUnit                 mAU;
    AUEventListenerRef        mParameterListener;
}

#pragma mark ____ PUBLIC FUNCTIONS ____
- (void)setAU:(AudioUnit)inAU;

#pragma mark ____ INTERFACE ACTIONS ____
- (IBAction)onVolumeSlider:(id)sender;
- (IBAction)onPresetSelect:(NSPopUpButton *)sender;

#pragma mark ____ PRIVATE FUNCTIONS
- (void)priv_populatePresetPopup;
- (void)priv_synchronizeUIWithParameterValues;
- (void)priv_addListeners;
- (void)priv_removeListeners;

#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____
- (void)priv_parameterListener:(void *)inObject parameter:(const AudioUnitParameter *)inParameter value:(Float32)inValue;

@end
