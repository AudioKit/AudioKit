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
    IBOutlet NSSlider *pitchOffsetSlider;
    IBOutlet NSTextField *pitchOffsetText;
    IBOutlet NSSlider *vibratoDepthSlider;
    IBOutlet NSTextField *vibratoDepthText;
    IBOutlet NSButton *monoCheckbox;
    IBOutlet NSButton *legatoCheckbox;
    IBOutlet NSSlider *glideRateSlider;
    IBOutlet NSTextField *glideRateText;
    
    IBOutlet NSSlider *ampAttackSlider;
    IBOutlet NSTextField *ampAttackText;
    IBOutlet NSSlider *ampDecaySlider;
    IBOutlet NSTextField *ampDecayText;
    IBOutlet NSSlider *ampSustainSlider;
    IBOutlet NSTextField *ampSustainText;
    IBOutlet NSSlider *ampReleaseSlider;
    IBOutlet NSTextField *ampReleaseText;

    IBOutlet NSButton *filterEnableCheckbox;
    IBOutlet NSSlider *filterCutoffSlider;
    IBOutlet NSTextField *filterCutoffText;
    IBOutlet NSSlider *filterEgStrengthSlider;
    IBOutlet NSTextField *filterEgStrengthText;
    IBOutlet NSSlider *filterResonanceSlider;
    IBOutlet NSTextField *filterResonanceText;
    
    IBOutlet NSSlider *filterAttackSlider;
    IBOutlet NSTextField *filterAttackText;
    IBOutlet NSSlider *filterDecaySlider;
    IBOutlet NSTextField *filterDecayText;
    IBOutlet NSSlider *filterSustainSlider;
    IBOutlet NSTextField *filterSustainText;
    IBOutlet NSSlider *filterReleaseSlider;
    IBOutlet NSTextField *filterReleaseText;

    IBOutlet NSPopUpButton *presetPopup;
    
    // Other Members
    AudioUnit               mAU;
    AUEventListenerRef      mParameterListener;
    NSURL*                  mPresetFolder;
}

#pragma mark ____ PUBLIC FUNCTIONS ____
- (void)setAU:(AudioUnit)inAU;

#pragma mark ____ INTERFACE ACTIONS ____
- (IBAction)onVolumeSlider:(NSSlider *)sender;
- (IBAction)onPitchOffsetSlider:(NSSlider *)sender;
- (IBAction)onPresetSelect:(NSPopUpButton *)sender;

#pragma mark ____ PRIVATE FUNCTIONS
- (void)priv_populatePresetPopup;
- (void)priv_synchronizeUIWithParameterValues;
- (void)priv_addListeners;
- (void)priv_removeListeners;

#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____
- (void)priv_parameterListener:(void *)inObject parameter:(const AudioUnitParameter *)inParameter value:(Float32)inValue;

@end
