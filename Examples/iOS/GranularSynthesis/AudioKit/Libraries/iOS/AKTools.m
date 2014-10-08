//
//  AKTools.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKTools.h"

@implementation AKTools

// -----------------------------------------------------------------------------
#  pragma mark - Common Math
// -----------------------------------------------------------------------------

+ (float)randomFloatFrom:(float)minimum to:(float)maximum;
{
    float width = maximum - minimum;
    return (((float) rand() / RAND_MAX) * width) + minimum;
}

+ (float)scaleValue:(float)value
        fromMinimum:(float)fromMinimum
        fromMaximum:(float)fromMaximum
          toMinimum:(float)toMinimum
          toMaximum:(float)toMaximum
{
    float percentage = (value-fromMinimum)/(fromMaximum - fromMinimum);
    float width = toMaximum - toMinimum;
    return toMinimum + percentage * width;
}

+ (float)scaleLogValue:(float)logValue
           fromMinimum:(float)fromMinimum
           fromMaximum:(float)fromMaximum
             toMinimum:(float)toMinimum
             toMaximum:(float)toMaximum
{
    float percentage = ((log(logValue) - log( fromMinimum)) / (log(fromMaximum) - log(fromMinimum)));
    float width = toMaximum - toMinimum;
    return toMinimum + percentage * width;
}

// -----------------------------------------------------------------------------
#  pragma mark - General UI
// -----------------------------------------------------------------------------

+ (void)setSlider:(UISlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = slider.maximumValue - slider.minimumValue;
    float sliderValue = slider.minimumValue + percentage * width;
    [slider setValue:sliderValue];
}

+ (void)setProgressView:(UIProgressView *)progressView
              withValue:(float)value
                minimum:(float)minimum
                maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    [progressView setProgress:percentage];
}

+ (float)scaleValueFromSlider:(UISlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum
{
    float width = slider.maximumValue - slider.minimumValue;
    float percentage = (slider.value - slider.minimumValue) / width;
    return minimum + percentage * (maximum - minimum);
}

+ (float)scaleLogValueFromSlider:(UISlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum
{
    float width = slider.maximumValue - slider.minimumValue;
    float percentage = (log(maximum) - log(minimum)) / width;
    
    return expf( log( minimum) + percentage * ( [slider value] - [slider minimumValue]) );
}

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------


+ (void)setSlider:(UISlider *)slider withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        [self setSlider:slider withValue:p.value minimum:p.minimum maximum:p.maximum];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        [self setSlider:slider withValue:p.value minimum:p.minimum maximum:p.maximum];
    }
    
}

+ (void)setProgressView:(UIProgressView *)progressView withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        [self setProgressView:progressView withValue:p.value minimum:p.minimum maximum:p.maximum];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p =(AKNoteProperty *)property;
        [self setProgressView:progressView withValue:p.value minimum:p.minimum maximum:p.maximum];
    }
    
}

+ (void)setProperty:(id)property withSlider:(UISlider *)slider
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        p.value = [self scaleValueFromSlider:slider minimum:p.minimum maximum:p.maximum];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p =(AKNoteProperty *)property;
        p.value = [self scaleValueFromSlider:slider minimum:p.minimum maximum:p.maximum];
    }
}

+ (void)setTextField:(UITextField *)textfield withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        textfield.text = [NSString stringWithFormat:@"%g", [(AKInstrumentProperty *)property value]];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        textfield.text = [NSString stringWithFormat:@"%g", [(AKNoteProperty *)property value]];
    }
}

+ (void)setLabel:(UILabel *)label withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p =(AKInstrumentProperty *)property;
        label.text = [NSString stringWithFormat:@"%g", p.value];
        
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        label.text = [NSString stringWithFormat:@"%g", p.value];
    }
}


// -----------------------------------------------------------------------------
#  pragma mark - MIDI
// -----------------------------------------------------------------------------

+ (float)midiNoteToFrequency:(int)note {
    return powf(2, (float)(note-69)/12.0)* 440.0f;
}

+ (float)scaleControllerValue:(float)value
                  fromMinimum:(float)minimum
                    toMaximum:(float)maximum
{
    return [self scaleValue:value
                fromMinimum:0
                fromMaximum:127
                  toMinimum:minimum
                  toMaximum:maximum];
}



@end