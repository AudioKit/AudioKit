//
//  Helper.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (void)setSlider:(UISlider *)slider 
        withValue:(float)value 
          minimum:(float)minimum 
          maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = [slider maximumValue] - [slider minimumValue];
    float sliderValue = [slider minimumValue] + percentage * width;
    [slider setValue:sliderValue];
}

+ (void)setSlider:(UISlider *)slider 
    usingProperty:(OCSProperty *)property 
{
    [self setSlider:slider 
          withValue:[property value] 
            minimum:[property minimumValue] 
            maximum:[property maximumValue]];
}


+ (float)scaleValueFromSlider:(UISlider *)slider 
                      minimum:(float)minimum 
                      maximum:(float)maximum
{   
    float width = [slider maximumValue] - [slider minimumValue];
    float percentage = ([slider value] - [slider minimumValue]) / width;
    return minimum + percentage * (maximum - minimum);
}

+ (float)randomFloatFrom:(float)minimum to:(float)maximum; 
{
    float width = maximum - minimum;
    return (((float) rand() / RAND_MAX) * width) + minimum;
}


+ (float)midiNoteToFrequency:(int)note {
    return powf(2, (float)note/12.0)* 440.0f;
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



@end
