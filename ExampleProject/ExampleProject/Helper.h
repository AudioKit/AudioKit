//
//  Helper.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (void)setSlider:(UISlider *)slider 
        withValue:(float)value 
          minimum:(float)minimum 
          maximum:(float)maximum;

+ (float)scaleValueFromSlider:(UISlider *)slider 
                      minimum:(float)minimum 
                      maximum:(float)maximum;


@end
