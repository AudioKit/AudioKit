//
//  AKChorus_UIView.h
//  AKChorus AUv2 Plugin
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AKChorus_UIView : NSView
{
    // IBOutlets
    
    // Other Members
    AudioUnit                 mAU;
    AUEventListenerRef        mParameterListener;
}

#pragma mark ____ PUBLIC FUNCTIONS ____
- (void)setAU:(AudioUnit)inAU;

#pragma mark ____ INTERFACE ACTIONS ____

#pragma mark ____ PRIVATE FUNCTIONS
- (void)priv_synchronizeUIWithParameterValues;
- (void)priv_addListeners;
- (void)priv_removeListeners;

#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____
- (void)priv_parameterListener:(void *)inObject parameter:(const AudioUnitParameter *)inParameter value:(Float32)inValue;

@end
