//
//  AKTools.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKManager.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

/// A suite of useful methods for working with AudioKit
@interface AKTools : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Common Math
// -----------------------------------------------------------------------------

/// Random number within a range
/// @param minimum Lower bound for the random number
/// @param maximum Upper bound for the random number
+ (float)randomFloatFrom:(float)minimum to:(float)maximum;

/// Scale a value from within one range to another
/// @param value Current value
/// @param fromMinimum Lower bound of the current value
/// @param fromMaximum Upper bound of the current value
/// @param toMinimum Lower bound of the output
/// @param toMaximum Upper bound of the output
+ (float)scaleValue:(float)value
        fromMinimum:(float)fromMinimum
        fromMaximum:(float)fromMaximum
          toMinimum:(float)toMinimum
          toMaximum:(float)toMaximum;

/// Scale the log of a value from one range to another
/// @param logValue Current value
/// @param fromMinimum Lower bound of the current value
/// @param fromMaximum Upper bound of the current value
/// @param toMinimum Lower bound of the output
/// @param toMaximum Upper bound of the output
+ (float)scaleLogValue:(float)logValue
           fromMinimum:(float)fromMinimum
           fromMaximum:(float)fromMaximum
             toMinimum:(float)toMinimum
             toMaximum:(float)toMaximum;

/// Scales the property with a scaling factor between 0 and 1. 0->minimum, 1->maximum
/// @param property An AKInstrumentProperty or AKNoteProperty to be scaled
/// @param scalingFactor Scaling factor between 0 and 1. 0->minimum, 1->maximum
+ (void)scaleProperty:(id)property
    withScalingFactor:(float)scalingFactor;

/// Scales the property with a scaling factor between 0 and 1. 0->maximum, 1->minimum
/// @param property An AKInstrumentProperty or AKNoteProperty to be scaled
/// @param scalingFactor Scaling factor between 0 and 1. 0->maximum, 1->minimum
+ (void)scaleProperty:(id)property
withInverseScalingFactor:(float)scalingFactor;

// -----------------------------------------------------------------------------
#  pragma mark - General UI
// -----------------------------------------------------------------------------

#if TARGET_OS_IPHONE
#define AKSlider UISlider
#elif TARGET_OS_MAC
#define AKSlider NSSlider
#endif

#if TARGET_OS_IPHONE
#define AKTextField UITextField
#elif TARGET_OS_MAC
#define AKTextField NSTextField
#endif

#if !TARGET_OS_TV
/// Reposition a slider's value and range
/// @param slider The slider to set up
/// @param value Current value of the slider
/// @param minimum Lower bound of the slider
/// @param maximum Upper bound of the slider
+ (void)setSlider:(AKSlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum;

/// Get the value from a slide with the minimum and maximum given here
/// @param slider The slider to get the value from
/// @param minimum Lower bound of the output
/// @param maximum Upper bound of the output
+ (float)scaleValueFromSlider:(AKSlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum;

/// Get the logvalue from a slide with the minimum and maximum given here
/// @param slider The slider to get the value from
/// @param minimum Lower bound of the output
/// @param maximum Upper bound of the output
+ (float)scaleLogValueFromSlider:(AKSlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum;

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------

/// Set a slider with an AKInstrumentProperty or AKNoteProperty
/// @param slider The slider to set up
/// @param property The AKInstrumentProperty or AKNoteProperty to use to set up the slider
+ (void)setSlider:(AKSlider *)slider withProperty:(id)property;

/// Set an AKInstrumentProperty or AKNoteProperty from a slider
/// @param property The AKInstrumentProperty or AKNoteProperty to set with the slider
/// @param slider The slider to use
+ (void)setProperty:(id)property withSlider:(AKSlider *)slider;

#endif

/// Populate a text field with the value from AKInstrumentProperty or AKNoteProperty
/// @param textfield The text field to set up
/// @param property The AKInstrumentProperty or AKNoteProperty to use to set up the slider
+ (void)setTextField:(AKTextField *)textfield withProperty:(id)property;


#if TARGET_OS_IPHONE
/// Set a progress view with an AKInstrumentProperty or AKNoteProperty
/// @param progressView The progress view to set up
/// @param property The AKInstrumentProperty or AKNoteProperty to use to set up the slider
+ (void)setProgressView:(UIProgressView *)progressView withProperty:(id)property;

/// Populate a label with the value from AKInstrumentProperty or AKNoteProperty
/// @param label The label to set up
/// @param property The AKInstrumentProperty or AKNoteProperty to use to set up the slider
+ (void)setLabel:(UILabel *)label withProperty:(id)property;
#endif

// -----------------------------------------------------------------------------
#  pragma mark - MIDI
// -----------------------------------------------------------------------------

/// Convert a MIDI note number to a frequency
/// @param note MIDI note as an integer
+ (float)midiNoteToFrequency:(int)note;

/// Scale a MIDI controller to a new range
/// @param value The current controller value
/// @param minimum Lower bound of the output
/// @param maximum Upper bound of the output
+ (float)scaleControllerValue:(float)value
                  fromMinimum:(float)minimum
                    toMaximum:(float)maximum;

@end
