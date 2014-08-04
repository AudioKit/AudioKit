//
//  AKOSXTools.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/27/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC

#import "AKOSXTools.h"

@implementation AKOSXTools

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

+ (void)setSlider:(NSSlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width =  slider.maxValue - slider.minValue;
    float sliderValue = slider.minValue + percentage * width;
    [slider setDoubleValue:sliderValue];
}

+ (float)scaleValueFromSlider:(NSSlider *)slider
                      minimum:(float)minimum
                      maximum:(float)maximum
{
    float width = slider.maxValue - slider.minValue;
    float percentage = (slider.doubleValue - slider.minValue) / width;
    return minimum + percentage * (maximum - minimum);
}

+ (float)scaleLogValueFromSlider:(NSSlider *)slider
                         minimum:(float)minimum
                         maximum:(float)maximum
{
    float width =  slider.maxValue - slider.minValue;
    float percentage = (log(maximum) - log(minimum)) / width;
    
    return expf( log( minimum) + percentage * (slider.doubleValue - slider.minValue) );
}

// -----------------------------------------------------------------------------
#  pragma mark - UI For Properties
// -----------------------------------------------------------------------------


+ (void)setSlider:(NSSlider *)slider withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        [self setSlider:slider
              withValue:[(AKInstrumentProperty *)property value]
                minimum:[(AKInstrumentProperty *)property minimum]
                maximum:[(AKInstrumentProperty *)property maximum]];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        [self setSlider:slider
              withValue:[(AKNoteProperty *)property value]
                minimum:[(AKNoteProperty *)property minimum]
                maximum:[(AKNoteProperty *)property maximum]];
    }
    
}

+ (void)setProperty:(id)property withSlider:(NSSlider *)slider
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        [(AKInstrumentProperty *)property setValue:[self scaleValueFromSlider:slider
                                                                      minimum:[(AKInstrumentProperty *)property minimum]
                                                                      maximum:[(AKInstrumentProperty *)property maximum]]];
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        [(AKNoteProperty *)property setValue:[self scaleValueFromSlider:slider
                                                                minimum:[(AKNoteProperty *)property minimum]
                                                                maximum:[(AKNoteProperty *)property maximum]]];
    }
}

+ (void)setTextField:(NSTextField *)textfield withProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        [textfield setStringValue:[NSString stringWithFormat:@"%g", [(AKInstrumentProperty *)property value]]];
        
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        [textfield setStringValue:[NSString stringWithFormat:@"%g", [(AKNoteProperty *)property value]]];
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
#endif