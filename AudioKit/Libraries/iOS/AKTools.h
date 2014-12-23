//
//  AKTools.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

+ (void)setSlider:(UISlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum;

+ (float)scaleValueFromSlider:(UISlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum;

+ (float)scaleLogValueFromSlider:(UISlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum;

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------

+ (void)setSlider:(UISlider *)slider withProperty:(id)property;
+ (void)setProgressView:(UIProgressView *)progressView withProperty:(id)property;
+ (void)setProperty:(id)property withSlider:(UISlider *)slider;
+ (void)setTextField:(UITextField *)textfield withProperty:(id)property;
+ (void)setLabel:(UILabel *)label withProperty:(id)property;


// -----------------------------------------------------------------------------
#  pragma mark - MIDI
// -----------------------------------------------------------------------------

+ (float)midiNoteToFrequency:(int)note;

+ (float)scaleControllerValue:(float)value
                  fromMinimum:(float)minimum
                    toMaximum:(float)maximum;


@end
