//
//  Helper.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSManager.h"

@interface Helper : NSObject

+ (void)setSlider:(UISlider *)slider 
        withValue:(float)value 
          minimum:(float)minimum 
          maximum:(float)maximum;

+ (void)setSlider:(UISlider *)slider 
    usingProperty:(OCSInstrumentProperty *)property;

+ (float)scaleValueFromSlider:(UISlider *)slider 
                      minimum:(float)minimum 
                      maximum:(float)maximum;

+ (float)randomFloatFrom:(float)minimum to:(float)maximum; 

+ (float)midiNoteToFrequency:(int)note;

+ (float)scaleValue:(float)value
        fromMinimum:(float)fromMinimum
        fromMaximum:(float)fromMaximum
          toMinimum:(float)toMinimum
          toMaximum:(float)toMaximum;

+ (float)scaleControllerValue:(float)value
                  fromMinimum:(float)minimum
                    toMaximum:(float)maximum;

@end

