//
//  AKTools.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AKManager.h"

@interface AKTools : NSObject


// -----------------------------------------------------------------------------
#  pragma mark - Common Math
// -----------------------------------------------------------------------------

+ (float)randomFloatFrom:(float)minimum to:(float)maximum;

+ (float)scaleValue:(float)value
        fromMinimum:(float)fromMinimum
        fromMaximum:(float)fromMaximum
          toMinimum:(float)toMinimum
          toMaximum:(float)toMaximum;

+ (float)scaleLogValue:(float)logValue
           fromMinimum:(float)fromMinimum
           fromMaximum:(float)fromMaximum
             toMinimum:(float)toMinimum
             toMaximum:(float)toMaximum;

// -----------------------------------------------------------------------------
#  pragma mark - General UI
// -----------------------------------------------------------------------------

+ (void)setSlider:(NSSlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum;

+ (float)scaleValueFromSlider:(NSSlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum;

+ (float)scaleLogValueFromSlider:(NSSlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum;

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------

+ (void)setSlider:(NSSlider *)slider withProperty:(id)property;
+ (void)setProperty:(id)property withSlider:(NSSlider *)slider;
+ (void)setTextField:(NSTextField *)textfield withProperty:(id)property;

// -----------------------------------------------------------------------------
#  pragma mark - MIDI
// -----------------------------------------------------------------------------

+ (float)midiNoteToFrequency:(int)note;

+ (float)scaleControllerValue:(float)value
                  fromMinimum:(float)minimum
                    toMaximum:(float)maximum;

@end
