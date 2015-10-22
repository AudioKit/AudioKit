//
//  AKTools.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
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

+ (void)scaleProperty:(id)property withScalingFactor:(float)scalingFactor
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        p.value = p.minimum + scalingFactor * (p.maximum - p.minimum);
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        p.value = p.minimum + scalingFactor * (p.maximum - p.minimum);
    }
}

+ (void)scaleProperty:(id)property withInverseScalingFactor:(float)scalingFactor
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        p.value = p.maximum - scalingFactor * (p.maximum - p.minimum);
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        p.value = p.maximum - scalingFactor * (p.maximum - p.minimum);
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - General UI
// -----------------------------------------------------------------------------


#if TARGET_OS_IPHONE
# define AKSlider UISlider
# define AKTextField UITextField
# define val value
# define max maximumValue
# define min minimumValue
# define text text
#elif TARGET_OS_MAC
# define AKSlider NSSlider
# define AKTextField NSTextField
# define val doubleValue
# define max maxValue
# define min minValue
# define text stringValue
#endif

#if !TARGET_OS_TV
+ (void)setSlider:(AKSlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = slider.max - slider.min;
    float sliderValue = slider.min + percentage * width;
    dispatch_async(dispatch_get_main_queue(), ^{
        slider.val = sliderValue;
    });
    [slider setNeedsDisplay];
}

+ (float)scaleValueFromSlider:(AKSlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum
{
    float width = slider.max - slider.min;
    float percentage = (slider.val - slider.min) / width;
    return minimum + percentage * (maximum - minimum);
}

+ (float)scaleLogValueFromSlider:(AKSlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum
{
    float width = slider.max - slider.min;
    float percentage = (log(maximum) - log(minimum)) / width;
    
    return expf( log(minimum) + percentage * (slider.val - slider.min) );
}
#endif

#if TARGET_OS_IPHONE
+ (void)setProgressView:(UIProgressView *)progressView
              withValue:(float)value
                minimum:(float)minimum
                maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressView setProgress:percentage];
    });
}
#endif

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------

#if !TARGET_OS_TV
+ (void)setSlider:(AKSlider *)slider withProperty:(id)property
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

+ (void)setProperty:(id)property withSlider:(AKSlider *)slider
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
#endif

+ (void)setTextField:(AKTextField *)textfield withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        dispatch_async(dispatch_get_main_queue(), ^{
            textfield.text = [NSString stringWithFormat:@"%g", p.value];
        });
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        dispatch_async(dispatch_get_main_queue(), ^{
            textfield.text = [NSString stringWithFormat:@"%g", p.value];
        });
    }
}

#if TARGET_OS_IPHONE
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

+ (void)setLabel:(UILabel *)label withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        dispatch_async(dispatch_get_main_queue(), ^{
            label.text = [NSString stringWithFormat:@"%g", p.value];
        });
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        dispatch_async(dispatch_get_main_queue(), ^{
            label.text = [NSString stringWithFormat:@"%g", p.value];
        });
    }
}
#endif

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
