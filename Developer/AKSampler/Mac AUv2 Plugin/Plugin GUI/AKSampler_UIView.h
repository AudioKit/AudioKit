//
//  AKSampler_UIView.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne on 2018-03-02.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AKSampler_UIView : NSView
{
    // IBOutlets
    
    // Other Members
    AudioUnit                 mAU;
    AUEventListenerRef        mAUEventListener;
}

#pragma mark ____ PUBLIC FUNCTIONS ____
- (void)setAU:(AudioUnit)inAU;

#pragma mark ____ INTERFACE ACTIONS ____

#pragma mark ____ PRIVATE FUNCTIONS
- (void)priv_synchronizeUIWithParameterValues;
- (void)priv_addListeners;
- (void)priv_removeListeners;

#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____
- (void)priv_eventListener:(void *) inObject event:(const AudioUnitEvent *)inEvent value:(Float32)inValue;

@end
