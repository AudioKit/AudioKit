//
//  Helper.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (void)setSlider:(NSSlider *)slider
        withValue:(float)value
          minimum:(float)minimum
          maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = [slider maxValue] - [slider minValue];
    float sliderValue = [slider minValue] + percentage * width;
    [slider takeFloatValueFrom:[NSNumber numberWithFloat:sliderValue]];
}

+ (float)randomFloatFrom:(float)minimum to:(float)maximum; 
{
    float width = maximum - minimum;
    return (((float) rand() / RAND_MAX) * width) + minimum;
}




@end
