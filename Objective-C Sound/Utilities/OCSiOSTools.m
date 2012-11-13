//
//  OCSiOSTools.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSiOSTools.h"

@implementation OCSiOSTools

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
    float width = [slider maximumValue] - [slider minimumValue];
    float percentage = ([slider value] - [slider minimumValue]) / width;
    return minimum + percentage * (maximum - minimum);
}

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------


+ (void)setSlider:(UISlider *)slider withProperty:(id)property
{
    if ([property isKindOfClass:[OCSInstrumentProperty class]])
    {
        [self setSlider:slider
              withValue:[(OCSInstrumentProperty *)property value]
                minimum:[(OCSInstrumentProperty *)property minimumValue]
                maximum:[(OCSInstrumentProperty *)property maximumValue]];
    }
    else if ([property isKindOfClass:[OCSNoteProperty class]])
    {
        [self setSlider:slider
              withValue:[(OCSNoteProperty *)property value]
                minimum:[(OCSNoteProperty *)property minimumValue]
                maximum:[(OCSNoteProperty *)property maximumValue]];
    }
    
}

+ (void)setProgressView:(UIProgressView *)progressView withProperty:(id)property
{
    if ([property isKindOfClass:[OCSInstrumentProperty class]])
    {
        [self setProgressView:progressView
                    withValue:[(OCSInstrumentProperty *)property value]
                      minimum:[(OCSInstrumentProperty *)property minimumValue]
                      maximum:[(OCSInstrumentProperty *)property maximumValue]];
    }
    else if ([property isKindOfClass:[OCSNoteProperty class]])
    {
        [self setProgressView:progressView
                    withValue:[(OCSNoteProperty *)property value]
                      minimum:[(OCSNoteProperty *)property minimumValue]
                      maximum:[(OCSNoteProperty *)property maximumValue]];
    }
    
}

+ (void)setProperty:(id)property withSlider:(UISlider *)slider
{
    if ([property isKindOfClass:[OCSInstrumentProperty class]])
    {
        [(OCSInstrumentProperty *)property setValue:[self scaleValueFromSlider:slider
                                                                       minimum:[(OCSInstrumentProperty *)property minimumValue]
                                                                       maximum:[(OCSInstrumentProperty *)property maximumValue]]];
    }
    else if ([property isKindOfClass:[OCSNoteProperty class]])
    {
        [(OCSNoteProperty *)property setValue:[self scaleValueFromSlider:slider
                                                                 minimum:[(OCSNoteProperty *)property minimumValue]
                                                                 maximum:[(OCSNoteProperty *)property maximumValue]]];
    }
}

+ (void)setTextField:(UITextField *)textfield withProperty:(id)property
{
    if ([property isKindOfClass:[OCSInstrumentProperty class]])
    {
        [textfield setText:[NSString stringWithFormat:@"%g", [(OCSInstrumentProperty *)property value]]];
        
    }
    else if ([property isKindOfClass:[OCSNoteProperty class]])
    {
        [textfield setText:[NSString stringWithFormat:@"%g", [(OCSNoteProperty *)property value]]];
    }
}

+ (void)setLabel:(UILabel *)label withProperty:(id)property
{
    if ([property isKindOfClass:[OCSInstrumentProperty class]])
    {
        [label setText:[NSString stringWithFormat:@"%g", [(OCSInstrumentProperty *)property value]]];
        
    }
    else if ([property isKindOfClass:[OCSNoteProperty class]])
    {
        [label setText:[NSString stringWithFormat:@"%g", [(OCSNoteProperty *)property value]]];
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
    return [self scaleValue:value fromMinimum:0 fromMaximum:127 toMinimum:minimum toMaximum:maximum];
}



@end