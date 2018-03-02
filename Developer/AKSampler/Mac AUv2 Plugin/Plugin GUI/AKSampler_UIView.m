//
//  AKSampler_UIView.m
//  AKSamplerUI
//
//  Created by Shane Dunne on 2018-03-02.
//

#import "AKSampler_UIView.h"

@implementation AKSampler_UIView


#pragma mark ____ (INIT /) DEALLOC ____

- (void)dealloc {
    [self priv_removeListeners];
    
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
    
    //[super dealloc];  // "ARC forbids explicit message send of 'dealloc'
}


#pragma mark ____ EXTRA STUFF not in .h file for some reason ____

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (BOOL) becomeFirstResponder {
    return YES;
}

- (BOOL) isOpaque {
    return YES;
}


#pragma mark ____ PUBLIC FUNCTIONS ____

- (void)setAU:(AudioUnit)inAU {
    // remove previous listeners
    if (mAU)
        [self priv_removeListeners];
    
    // register for resize notification and data changes for the graph view
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleGraphDataChanged:) name: kGraphViewDataChangedNotification object: graphView];
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleGraphSizeChanged:) name: NSViewFrameDidChangeNotification  object: graphView];
//
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(beginGesture:) name: kGraphViewBeginGestureNotification object: graphView];
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(endGesture:) name: kGraphViewEndGestureNotification object: graphView];
    
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
//    if (mAU) {
//        AUEventListenerCreate(EventListenerDispatcher, self,
//                              CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 0.05, 0.05,
//                              &mAUEventListener));
//
//        AudioUnitEvent auEvent;
//        AudioUnitParameter parameter = {mAU, kFilterParam_CutoffFrequency, kAudioUnitScope_Global, 0 };
//        auEvent.mArgument.mParameter = parameter;
//
//        addParamListener (mAUEventListener, self, &auEvent);
//
//        auEvent.mArgument.mParameter.mParameterID = kFilterParam_Resonance;
//        addParamListener (mAUEventListener, self, &auEvent);
//
//        /* Add a listener for the changes in our custom property */
//        /* The Audio unit will send a property change when the unit is intialized */
//        auEvent.mEventType = kAudioUnitEvent_PropertyChange;
//        auEvent.mArgument.mProperty.mAudioUnit = mAU;
//        auEvent.mArgument.mProperty.mPropertyID = kAudioUnitCustomProperty_FilterFrequencyResponse;
//        auEvent.mArgument.mProperty.mScope = kAudioUnitScope_Global;
//        auEvent.mArgument.mProperty.mElement = 0;
//        AUEventListenerAddEventType (mAUEventListener, self, &auEvent);
//    }
}

- (void)priv_removeListeners
{
    //if (mAUEventListener) AUListenerDispose(mAUEventListener);
    mAUEventListener = NULL;
    mAU = NULL;
}

- (void)priv_synchronizeUIWithParameterValues
{
}


#pragma mark ____ LISTENER CALLBACK DISPATCHEE ____

- (void)priv_eventListener:(void *) inObject event:(const AudioUnitEvent *)inEvent value:(Float32)inValue
{
//    switch (inEvent->mEventType) {
//        case kAudioUnitEvent_ParameterValueChange:                    // Parameter Changes
//            switch (inEvent->mArgument.mParameter.mParameterID) {
//                case kFilterParam_CutoffFrequency:                    // handle cutoff frequency parameter
//                    [cutoffFrequencyField setFloatValue: inValue];    // update the frequency text field
//                    [graphView setFreq: inValue];                    // update the graph's frequency visual state
//                    break;
//                case kFilterParam_Resonance:                        // handle resonance parameter
//                    [resonanceField setFloatValue: inValue];        // update the resonance text field
//                    [graphView setRes: inValue];                    // update the graph's gain visual state
//                    break;
//            }
//            // get the curve data from the audio unit
//            [self updateCurve];
//            break;
//        case kAudioUnitEvent_BeginParameterChangeGesture:            // Begin gesture
//            [graphView handleBeginGesture];                            // notify graph view to update visual state
//            break;
//        case kAudioUnitEvent_EndParameterChangeGesture:                // End gesture
//            [graphView handleEndGesture];                            // notify graph view to update visual state
//            break;
//        case kAudioUnitEvent_PropertyChange:                        // custom property changed
//            if (inEvent->mArgument.mProperty.mPropertyID == kAudioUnitCustomProperty_FilterFrequencyResponse)
//                [self updateCurve];
//            break;
//    }
}

@end
